# Terraform on AWS: From Zero to Apply

An Instruqt 2.0 lab that teaches Terraform fundamentals against a real,
throwaway AWS account. Learners write HCL from scratch, run the full
init/plan/apply loop, refactor with variables and outputs, migrate state to an
S3 backend, and destroy everything.

- **Duration:** ~2 hours (90 minutes of content, 30 minutes of slack)
- **Level:** Beginner — no prior Terraform assumed
- **Cloud cost:** effectively zero (S3 buckets and VPC networking only; EC2
  instances and every expensive service are blocked by SCP)

---

## Before you import

This lab uses the `aws_account` sandbox resource, which provisions a real
throwaway AWS account per session. That requires an AWS cloud provider to be
configured for your Instruqt organisation first:

**Settings → Cloud Providers → AWS**

Without it, sandbox creation fails with a cloud provider error. See
<https://docs.labs.instruqt.com/settings/cloud-providers/>.

You also need the Instruqt CLI if you want to validate locally:

```bash
instruqt version
```

## Getting it into Instruqt

1. Create a new **empty** GitHub repository (no README, no .gitignore).
2. Push this directory to it:

   ```bash
   git init
   git branch -m main
   git add .
   git commit -m "Terraform on AWS lab"
   git remote add origin git@github.com:YOUR-ORG/YOUR-REPO.git
   git push -u origin main
   ```

3. Connect the repository in Instruqt (**Version Control → Integrating
   External VCS**).

Every push to `main` redeploys the lab. Validation runs automatically on
deploy; run it yourself first with:

```bash
instruqt lab validate
```

### If validation says files "do not exist"

If you see a wall of errors like `page file "instructions/01-welcome.md" does
not exist` or `script file "scripts/task/.../check_*.sh" not found` while the
root `.hcl` files validate fine, the HCL is not the problem — the
subdirectories did not reach the branch Instruqt is reading.

Check what the branch actually contains:

```bash
git ls-files | wc -l          # should be 60
git ls-files instructions notes scripts files
git branch --show-current     # must match the lab's Ref in the UI
```

Two common causes: the lab's **Ref** in the Instruqt UI points at a branch
that only has the root files, or the repo was populated by copying individual
files rather than the whole tree. Push the full tree to the branch the lab is
configured to read:

```bash
git add -A && git commit -m "Add lab content" && git push origin HEAD
```

Also confirm the lab's **Path** in the UI is `/` and that the `.hcl` files sit
at the repository root, not inside a subfolder.

---

## Repository layout

```
.
├── main.hcl                  Lab metadata, settings, chapter/page structure
├── variables.hcl             Tunable inputs (region, TF version, image…)
├── sandbox.hcl               Network, AWS account, state backend, workstation
├── tabs.hcl                  Terminal, editor, credentials panel, notes
├── layouts.hcl               Two UI layouts: workbench and reading
├── pages.hcl                 Page resources → markdown + activity wiring
├── tasks.hcl                 7 tasks, 14 conditions, all check/solve scripts
│
├── instructions/             Learner-facing markdown, one file per page
│   ├── 01-welcome.md
│   ├── 02-first-configuration.md
│   ├── 03-init-and-plan.md
│   ├── 04-apply.md
│   ├── 05-variables-and-outputs.md
│   ├── 06-remote-state.md
│   └── 07-cleanup.md
│
├── notes/                    Docked reference tabs
│   ├── terraform-cheatsheet.md
│   └── troubleshooting.md
│
├── files/
│   ├── policies/
│   │   ├── student-policy.json      IAM policy for the learner's AWS user
│   │   └── guardrails-scp.json      SCP ceiling: region lock, no paid services
│   └── workspace/                   Seeded into /workspace in the container
│       ├── main.tf                  Starter file (comments only)
│       ├── README.md
│       └── gitignore.example        Renamed to .gitignore at setup
│
├── terraform/state-backend/  Author-side TF, applied by the sandbox before
│   ├── versions.tf           the session starts. Creates the versioned,
│   ├── variables.tf          encrypted S3 bucket used in Chapter 6 and
│   ├── main.tf               exposes its name as $TF_STATE_BUCKET.
│   └── outputs.tf
│
├── scripts/
│   ├── exec/install_tooling/script.sh    Installs Terraform + AWS CLI, seeds
│   └── task/<task>/                      workspace, sets up the shell
│       ├── check_*.sh                    Validation — exit 0 means complete
│       └── solve_*.sh                    Runs when a learner skips
│
├── solutions/                Reference answers for chapters 2, 5 and 6
└── assets/                   Images, PDFs, diagrams (empty by default)
```

---

## How the pieces connect

```
aws_account.lab ──┬──► terraform.state_backend ──► $TF_STATE_BUCKET
                  │        (creates the state bucket up front)
                  │
                  ├──► container.workstation (AWS creds as env vars)
                  │         ▲
                  │         ├── exec.install_tooling  (Terraform + AWS CLI)
                  │         ├── terminal.workstation  ──┐
                  │         └── editor.workspace       ─┤
                  │                                     ├─► layout.workbench
                  └──► cloud_credentials.aws ───────────┘

page.* ──► task.* ──► scripts/task/*/check_*.sh
   └────► instructions/*.md   (<instruqt-task id="..."> matches the
                               key in the page's `activities` map)
```

The `<instruqt-task id="x">` tag in markdown resolves against the
`activities` map on the page resource — **not** the task resource name. If a
task does not render, that mapping is where to look.

---

## Chapters and validation

| # | Chapter | Task | Conditions checked |
|---|---------|------|--------------------|
| 1 | Welcome & Environment Check | `verify_environment` | `checks/terraform.txt` holds a version string; `checks/identity.json` is valid STS output |
| 2 | Your First Configuration | `first_config` | `main.tf` declares `hashicorp/aws` + a provider with a region; `aws_s3_bucket.lab` with a unique name |
| 3 | Init & Plan | `init_and_plan` | `.terraform/` and a lock file naming the AWS provider; a saved `tfplan` that creates ≥1 resource |
| 4 | Apply & Verify | `apply_infra` | `aws_s3_bucket.lab` in state; bucket confirmed live via `head-bucket` |
| 5 | Variables, Outputs & a VPC | `variables_and_outputs` | `variables.tf` declares three variables; VPC + subnet in state; `bucket_name` and `vpc_id` outputs non-empty |
| 6 | Remote State on S3 | `remote_state` | `backend.tf` has an `s3` backend pointing at `$TF_STATE_BUCKET`; state object exists in the bucket |
| 7 | Destroy & Wrap-Up | `cleanup` | No `aws_*` resources left in state |

Every condition has a `solve` script, so a stuck learner can skip without
blocking the rest of the lab. Check scripts print an actionable message on
failure, and `failure_message` in `tasks.hcl` gives the exact command to run.

---

## Customising

Almost everything is in `variables.hcl`:

| Variable | Default | Notes |
|----------|---------|-------|
| `aws_region` | `us-east-1` | Changing this also means editing `guardrails-scp.json`, which pins the region |
| `terraform_version` | `1.9.8` | Used for both the learner CLI and the sandbox `terraform` resource |
| `workstation_image` | `ubuntu:24.04` | See start-up time below |
| `workspace_dir` | `/workspace` | Where learners write code |
| `enable_remote_state` | `true` | Set `false` to skip the S3 state bucket entirely |

### Making it start faster

The workstation installs Terraform and the AWS CLI at boot, which adds roughly
60–90 seconds. For production use, build an image with both baked in using the
Instruqt image builder, then:

```hcl
variable "workstation_image" {
  default = "your-registry/terraform-workstation:1.9.8"
}
```

and delete `resource "exec" "install_tooling"` from `sandbox.hcl`, keeping only
the workspace-seeding portion of the script.

### Dropping the remote state chapter

Set `enable_remote_state = false`, remove the `remote_state` page from
`main.hcl`'s `state_and_cleanup` chapter, and delete `resource "page"
"remote_state"` and `resource "task" "remote_state"`. The `terraform`
sandbox resource disables itself and `$TF_STATE_BUCKET` becomes empty.

### Letting learners launch EC2 instances

Remove the `NoComputeInstancesInThisLab` statement from
`files/policies/guardrails-scp.json` and add `ec2:RunInstances`,
`ec2:TerminateInstances`, `ec2:StopInstances`, `ec2:StartInstances` and
`ec2:CreateKeyPair` to `files/policies/student-policy.json`. Add an instance
type condition so learners cannot start anything expensive. **This changes the
cost profile of the lab** — the current configuration is deliberately free.

---

## Testing before you ship

Work through it yourself as a learner, then test the failure paths — that is
where labs break:

1. Do nothing and confirm every task stays incomplete.
2. Complete each task the intended way and confirm it goes green.
3. Hit **Skip** on each task and confirm the solve script leaves the workspace
   in a state where the *next* chapter still works.
4. Break something on purpose (a typo in `main.tf`, a duplicate bucket name)
   and confirm the failure message points somewhere useful.

Scripts can be exercised directly in the terminal:

```bash
WORKSPACE=/workspace bash /path/to/check_provider.sh; echo "exit=$?"
```

---

## Notes on the AWS policies

`student-policy.json` is the learner's IAM policy: S3 for buckets and state,
EC2 describe for read access, and the specific VPC/subnet/security-group/route
actions the lab needs. Nothing broader.

`guardrails-scp.json` is a Service Control Policy — a ceiling that applies
even if the IAM policy is wrong. It denies every region except the lab region,
blocks EC2 instance launches and NAT gateways, blocks the expensive managed
services (EKS, RDS, SageMaker, Bedrock and friends), and protects the sandbox
itself from IAM and CloudTrail tampering.

Both are deliberately conservative. If a learner hits `AccessDenied` on
something the lab genuinely needs, widen `student-policy.json` — not the SCP.

---

## Source documentation

Built against the Instruqt 2.0 (Labs) HCL schema:

- Terraform sandbox resource — <https://docs.labs.instruqt.com/reference/sandbox/utilities/terraform/>
- AWS account — <https://docs.labs.instruqt.com/reference/sandbox/cloud/aws/account/>
- Tasks — <https://docs.labs.instruqt.com/reference/content/task/>
- Pages — <https://docs.labs.instruqt.com/reference/content/page/>
- Layouts — <https://docs.labs.instruqt.com/reference/content/layout/>
- Markdown components — <https://docs.labs.instruqt.com/ui-overview/adding-content/markdown-editor/>

## Licence

MIT — see `LICENSE`.

# Terraform cheat sheet

## The core loop

| Command | What it does |
|---------|--------------|
| `terraform init` | Download providers, prepare the directory |
| `terraform fmt` | Rewrite files to canonical style |
| `terraform validate` | Check syntax and internal consistency |
| `terraform plan` | Show what would change |
| `terraform apply` | Make the changes |
| `terraform destroy` | Remove everything in state |

## Useful flags

| Flag | Use |
|------|-----|
| `-out=tfplan` | Save a plan to a file |
| `terraform apply tfplan` | Apply a saved plan, no prompt |
| `-auto-approve` | Skip the confirmation prompt |
| `-target=aws_s3_bucket.lab` | Act on one resource only (escape hatch, not a habit) |
| `-refresh=false` | Skip refreshing real-world state - faster, less accurate |
| `-no-color` | Plain output, for logs and CI |
| `-upgrade` | On `init`, allow newer provider versions |

## Inspecting things

```bash
terraform state list                      # every resource address
terraform state show aws_s3_bucket.lab    # all attributes of one resource
terraform output                          # all outputs
terraform output -raw vpc_id              # one output, no quotes
terraform show -json tfplan | jq          # machine-readable plan
terraform providers                       # provider requirements tree
terraform graph                           # dependency graph in DOT format
```

## Plan symbols

| Symbol | Meaning |
|--------|---------|
| `+` | create |
| `-` | destroy |
| `~` | update in place |
| `-/+` | destroy and recreate — read this one carefully |

## Block anatomy

```hcl
resource "TYPE" "LOCAL_NAME" {
  argument = "value"
}
```

Reference it elsewhere as `TYPE.LOCAL_NAME.ATTRIBUTE`, for example
`aws_vpc.lab.id`.

| Block | Purpose |
|-------|---------|
| `terraform {}` | Version constraints, required providers, backend |
| `provider "aws" {}` | How to reach the API |
| `resource {}` | Something Terraform creates and owns |
| `data {}` | Something Terraform reads but does not own |
| `variable {}` | Input |
| `output {}` | Result exposed to the caller |
| `locals {}` | Named intermediate values |
| `module {}` | A reusable group of resources |

## Variable precedence

Later wins:

1. `default` in the `variable` block
2. `TF_VAR_name` environment variable
3. `terraform.tfvars`, then `*.auto.tfvars`
4. `-var-file=...` on the command line
5. `-var name=value` on the command line

## Files

| File | Commit it? |
|------|-----------|
| `*.tf` | Yes |
| `.terraform.lock.hcl` | **Yes** — this is the point of a lock file |
| `.terraform/` | No |
| `terraform.tfstate` | No — use a remote backend |
| `*.tfvars` | No — usually holds secrets |
| `tfplan` | No |

## This lab's environment variables

```bash
$AWS_REGION        # the only region allowed here
$AWS_ACCOUNT_ID    # your throwaway account
$LAB_SUFFIX        # unique string for this session
$LAB_BUCKET        # tf-lab-<suffix>
$TF_STATE_BUCKET   # pre-made remote state bucket
$WORKSPACE         # /workspace
```

Aliases: `tf`, `tfi`, `tfp`, `tfa`, `tfd`.

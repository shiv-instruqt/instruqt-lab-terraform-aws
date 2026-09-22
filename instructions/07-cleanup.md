# Destroy and wrap up

The last command of the Terraform lifecycle, and the one that keeps cloud
bills survivable.

## See what will go

`destroy` has a plan mode too. Always look before you leap:

```bash,run
terraform plan -destroy
```

Every resource is marked `-`, and the summary says `0 to add, 0 to change,
3 to destroy`.

## Destroy

```bash,run
terraform destroy -auto-approve
```

Terraform tears resources down in reverse dependency order - the subnet before
the VPC, because the VPC cannot be deleted while something lives in it. The
same graph that ordered creation runs backwards.

Confirm state is empty:

```bash,run
terraform state list && echo "--- nothing above this line means success ---"
```

And confirm with AWS directly:

```bash,run
aws s3 ls | grep "$LAB_SUFFIX" || echo "Bucket is gone."
```

<instruqt-task id="cleanup"></instruqt-task>

## What you learned

You ran the full loop that every Terraform user runs daily:

**write** a description of what you want, **init** to fetch the providers,
**plan** to see the diff, **apply** to make it real, **destroy** to take it
away.

Along the way you met the ideas that actually matter: providers and version
pinning, the lock file, resource references building a dependency graph,
variables and outputs as a configuration's interface, and state as the fragile
secret-bearing thing that must be stored remotely and versioned.

## Where to go next

The natural next steps, roughly in order of usefulness:

**Modules.** Group resources into a reusable unit with its own variables and
outputs. Once you have written the same VPC three times you will want this.

**Workspaces or directory-per-environment.** Run the same configuration for
dev, staging and prod without copy-paste.

**Data sources.** `data "aws_ami" "ubuntu"` and friends let you read things you
did not create.

**CI/CD.** `terraform plan` on every pull request, `terraform apply` on merge.
This is where saved plan files and state locking stop being academic.

**`terraform import`.** Bring existing, hand-built infrastructure under
Terraform's management.

The registry at `registry.terraform.io` documents every resource and data
source for every provider. It is the reference you will keep open forever.

## Before you close this tab

Your sandbox AWS account and everything in it is deleted automatically when
this session ends, so nothing you leave behind will cost anything. Running
`destroy` yourself is still the habit worth building.

# Troubleshooting

## "Error: Inconsistent dependency lock file"

You changed `required_providers` after running `init`.

```bash
terraform init -upgrade
```

## "Error: Initialization required"

`plan` or `apply` before `init`, or you added a new provider.

```bash
terraform init
```

## "BucketAlreadyExists" / "BucketAlreadyOwnedByYou"

S3 bucket names are globally unique across every AWS account on earth. Your
name collided with someone else's.

```bash
echo $LAB_BUCKET     # use this exact name
```

If you already own it, it is in your account from an earlier attempt - either
import it or pick a new suffix.

## "AccessDenied" or "UnauthorizedOperation"

This sandbox account is deliberately restricted. It allows S3, VPC networking
and read-only EC2 in one region only. Launching EC2 instances, RDS, EKS and
other paid services is blocked by policy — that is expected, not a bug.

Check you are who you think you are:

```bash
aws sts get-caller-identity
```

## "No valid credential sources found"

Credentials live in environment variables in this lab. If a terminal has lost
them:

```bash
env | grep -E 'AWS_(ACCESS|SECRET|REGION|DEFAULT)'
```

If they are missing, open a fresh terminal tab. Never run `aws configure` -
it will shadow the working credentials with empty ones.

## "Error acquiring the state lock"

A previous run died mid-apply. Confirm nothing else is running, then:

```bash
terraform force-unlock <LOCK_ID>
```

Only ever do this when you are certain no other apply is in flight.

## Plan says "-/+ destroy and then create replacement"

You changed an argument that cannot be updated in place. Terraform names the
culprit in the plan output, marked `# forces replacement`. On a bucket that is
harmless. On anything holding data, stop and think first.

## `terraform validate` passes but `apply` fails

`validate` only checks syntax and internal consistency. It never calls AWS.
Permission errors, name collisions and quota limits only surface at apply
time.

## Terraform seems to have forgotten everything

You are probably in the wrong directory, or state moved.

```bash
pwd                    # should be /workspace
ls -la *.tf
terraform state list
```

## Everything is broken and you want to start over

```bash
cd $WORKSPACE
terraform destroy -auto-approve   # if state is intact
rm -rf .terraform .terraform.lock.hcl terraform.tfstate* tfplan
```

Then re-do the chapter from `terraform init`. Nothing here is precious.

## Nothing above helped

Every task has a **Skip** option that applies the reference solution, so a
stuck chapter never blocks the rest of the lab. Use it and read the code it
wrote — that is a legitimate way to learn.

# Remote state

Your state file is sitting in the working directory. That is fine for one
person on one machine, and it falls apart the moment anyone else is involved:

- Your colleague has no copy, so their `apply` tries to create everything again.
- Two people applying at once corrupt each other's writes.
- The file contains secrets in plaintext, on a laptop.
- Delete the directory and Terraform forgets your infrastructure exists.

The fix is a **backend**: Terraform stores state somewhere shared instead of
locally.

## The bucket is already there

This lab pre-provisioned an S3 bucket for exactly this purpose, using
Terraform itself - the lab author's configuration ran before your session
started and handed you the bucket name:

```bash,run
echo $TF_STATE_BUCKET
```

```bash,run
aws s3api get-bucket-versioning --bucket "$TF_STATE_BUCKET"
```

Versioning is on. Every state write keeps the previous version, so a corrupted
or truncated state can be rolled back. Do this on any real state bucket.

## Declare the backend

Create `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket  = "REPLACE_WITH_TF_STATE_BUCKET"
    key     = "labs/terraform-aws-fundamentals/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
```

Or write it with the real value already substituted:

```bash,run
cat > backend.tf <<EOF
terraform {
  backend "s3" {
    bucket  = "$TF_STATE_BUCKET"
    key     = "labs/terraform-aws-fundamentals/terraform.tfstate"
    region  = "$AWS_REGION"
    encrypt = true
  }
}
EOF
cat backend.tf
```

Two constraints worth knowing. A backend block cannot use variables or any
interpolation - it is read before Terraform evaluates anything else, so every
value must be a literal. And `key` is the object path inside the bucket; give
each configuration its own key or they will overwrite each other's state.

## Migrate

Changing the backend means re-initialising:

```bash,run
terraform init -migrate-state -force-copy
```

Terraform copies your existing local state up to S3. `-force-copy` skips the
interactive confirmation.

Confirm it landed:

```bash,run
aws s3 ls "s3://$TF_STATE_BUCKET/labs/terraform-aws-fundamentals/"
```

And confirm Terraform still sees your resources - the state moved, nothing was
recreated:

```bash,run
terraform state list && terraform plan
```

`No changes.` State is now remote, encrypted at rest, versioned, and readable
by anyone with access to the bucket.

## What is missing

Real setups also need **locking** so two people cannot write state at once.
Recent Terraform versions support S3-native locking with `use_lockfile = true`
in the backend block; older ones used a DynamoDB table. Either way, locking is
not optional on a team.

<instruqt-task id="remote_state"></instruqt-task>

# Your first configuration

Terraform reads every file ending in `.tf` in the current directory. There is
no entry point and no import statements - the directory *is* the program.

Open `main.tf` in the **Code Editor** tab, or edit it in the terminal with
`vim main.tf`. Right now it contains only comments.

## Part 1: tell Terraform which provider you need

A **provider** is the plugin that knows how to talk to a specific API. The AWS
provider knows how to turn `aws_s3_bucket` into the right API calls.

Two blocks do this. The first declares which providers this configuration
depends on and pins the version:

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

The second configures the provider itself:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

`~> 5.0` means "any 5.x release, but not 6.0". Pinning matters: a major
provider release can rename arguments, and you do not want that happening
during a deploy you did not trigger.

## Part 2: declare a resource

A **resource** block is a description of something you want to exist. It has
three parts: the keyword, the resource *type*, and a *local name* you choose.

```hcl
resource "aws_s3_bucket" "lab" {
  bucket = "REPLACE-ME"
}
```

`aws_s3_bucket` is fixed by the provider. `lab` is yours - it is how you refer
to this resource elsewhere in your config, as `aws_s3_bucket.lab`.

For the bucket name, use the value in `$LAB_BUCKET`:

```bash,run
echo $LAB_BUCKET
```

Tags are worth adding out of habit. In a shared account, untagged resources
are the ones nobody can identify and nobody dares delete:

```hcl
  tags = {
    Name      = "tf-lab-xxxx"
    ManagedBy = "Terraform"
  }
```

## Put it together

Your `main.tf` needs all three blocks: `terraform`, `provider "aws"`, and
`resource "aws_s3_bucket" "lab"`. Write it now.

When you think it is right, check the formatting and syntax:

```bash,run
terraform fmt && terraform validate
```

`terraform validate` will complain that the directory is not initialised -
that is expected, and it is exactly what the next chapter is about. As long as
`terraform fmt` runs without a parse error, your HCL is syntactically valid.

<instruqt-task id="first_config"></instruqt-task>

> **Stuck?** `terraform fmt` rewrites your file to canonical style. If it
> reports an error instead, you have an unbalanced brace or a missing `=`.

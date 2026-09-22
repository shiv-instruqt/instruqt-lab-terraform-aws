# Variables, outputs and a VPC

Your configuration works, but every value is hardcoded. To deploy it to a
second region or a second environment you would copy the file and edit it -
and now you have two files that drift apart.

Variables fix that.

## Input variables

Create `variables.tf`:

```hcl
variable "aws_region" {
  type        = string
  description = "AWS region to deploy into."
  default     = "us-east-1"
}

variable "bucket_suffix" {
  type        = string
  description = "Unique suffix so the bucket name does not collide globally."
}

variable "environment" {
  type        = string
  description = "Environment name applied as a tag."
  default     = "training"
}
```

`bucket_suffix` has no default, which makes it **required**. Terraform will
refuse to plan until it has a value.

Provide values in `terraform.tfvars`, which Terraform loads automatically:

```bash,run
cat > terraform.tfvars <<EOF
aws_region    = "$AWS_REGION"
bucket_suffix = "$LAB_SUFFIX"
environment   = "training"
EOF
cat terraform.tfvars
```

> `.tfvars` files routinely hold credentials and are excluded by your
> `.gitignore`. Commit a `terraform.tfvars.example` instead.

## Use them

Rewrite `main.tf` to reference variables with `var.<name>`. A `locals` block
is useful for values you derive once and reuse:

```hcl
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Lab         = "terraform-aws-fundamentals"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

locals {
  name_prefix = "tf-lab-${var.bucket_suffix}"
}

resource "aws_s3_bucket" "lab" {
  bucket = local.name_prefix

  tags = {
    Name = local.name_prefix
  }
}
```

`default_tags` applies those tags to every resource the provider creates. One
block, and your whole estate is tagged consistently.

## Add a network

Create `network.tf`. This is where resource *references* start to matter:

```hcl
resource "aws_vpc" "lab" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_subnet" "lab" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = "10.42.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${local.name_prefix}-subnet"
  }
}
```

Look at `vpc_id = aws_vpc.lab.id`. You never wrote the VPC's ID anywhere -
it does not exist until AWS creates it. That reference does two things: it
fills in the value at apply time, and it tells Terraform the subnet depends on
the VPC, so the VPC is created first. Terraform builds a dependency graph from
these references and parallelises everything that is independent.

This is why you almost never need `depends_on`.

## Outputs

Create `outputs.tf`:

```hcl
output "bucket_name" {
  value       = aws_s3_bucket.lab.id
  description = "Name of the S3 bucket created by this configuration."
}

output "vpc_id" {
  value       = aws_vpc.lab.id
  description = "ID of the VPC."
}

output "subnet_id" {
  value       = aws_subnet.lab.id
  description = "ID of the subnet."
}
```

Outputs are the public interface of a configuration - what you expose to a
human, a pipeline, or another Terraform configuration reading your state.

## Apply

```bash,run
terraform plan
```

You should see 2 to add and 0 to destroy. The bucket is unchanged: you
replaced a hardcoded string with a variable that resolves to the same value,
and Terraform compares values, not source code.

```bash,run
terraform apply -auto-approve
```

```bash,run
terraform output
```

```bash,run
terraform output -raw vpc_id
```

`-raw` prints the bare value with no quotes, which is what you want when
piping into another command.

<instruqt-task id="variables_and_outputs"></instruqt-task>

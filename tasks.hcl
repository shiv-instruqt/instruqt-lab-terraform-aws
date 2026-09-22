# ---------------------------------------------------------------------------
# tasks.hcl
# One task per chapter. Each task holds one or more conditions; a condition is
# marked complete when its check script exits 0.
#
# Every task repeats the same config block on purpose - it keeps each task
# self-contained and independently testable.
# ---------------------------------------------------------------------------

# Chapter 1 -----------------------------------------------------------------
resource "task" "verify_environment" {
  description     = "Confirm Terraform and the AWS CLI are working in your sandbox"
  success_message = "Environment verified. Terraform can talk to AWS - let's write some code."

  config {
    target            = resource.container.workstation
    user              = "root"
    working_directory = variable.workspace_dir
    timeout           = "60s"

    environment = {
      AWS_ACCESS_KEY_ID     = resource.aws_account.lab.user.0.access_key_id
      AWS_SECRET_ACCESS_KEY = resource.aws_account.lab.user.0.secret_access_key
      AWS_DEFAULT_REGION    = variable.aws_region
      AWS_PAGER             = ""
      WORKSPACE             = variable.workspace_dir
      LAB_SUFFIX            = resource.random_id.lab.hex
    }
  }

  condition "tooling_recorded" {
    description = "Record the Terraform version to checks/terraform.txt"

    check {
      script          = "scripts/task/verify_environment/check_tooling.sh"
      failure_message = "checks/terraform.txt is missing or does not contain a Terraform version. Run: terraform version | tee checks/terraform.txt"
    }

    solve {
      script = "scripts/task/verify_environment/solve_tooling.sh"
    }
  }

  condition "identity_recorded" {
    description = "Record your AWS identity to checks/identity.json"

    check {
      script          = "scripts/task/verify_environment/check_identity.sh"
      failure_message = "checks/identity.json is missing or has no Account field. Run: aws sts get-caller-identity | tee checks/identity.json"
    }

    solve {
      script = "scripts/task/verify_environment/solve_identity.sh"
    }
  }
}

# Chapter 2 -----------------------------------------------------------------
resource "task" "first_config" {
  description     = "Write your first Terraform configuration"
  success_message = "Nice. You have a provider requirement and your first resource block."

  config {
    target            = resource.container.workstation
    user              = "root"
    working_directory = variable.workspace_dir
    timeout           = "60s"

    environment = {
      WORKSPACE  = variable.workspace_dir
      LAB_SUFFIX = resource.random_id.lab.hex
      LAB_BUCKET = "tf-lab-${resource.random_id.lab.hex}"
      AWS_REGION = variable.aws_region
    }
  }

  condition "provider_declared" {
    description = "Declare the hashicorp/aws provider in main.tf"

    check {
      script          = "scripts/task/first_config/check_provider.sh"
      failure_message = "main.tf needs a terraform block with required_providers containing source \"hashicorp/aws\", plus a provider \"aws\" block with a region."
    }

    solve {
      script = "scripts/task/first_config/solve_first_config.sh"
    }
  }

  condition "bucket_declared" {
    description = "Add an aws_s3_bucket resource named \"lab\""

    check {
      script          = "scripts/task/first_config/check_bucket_resource.sh"
      failure_message = "main.tf needs resource \"aws_s3_bucket\" \"lab\" with a bucket name ending in your lab suffix."
    }

    solve {
      script = "scripts/task/first_config/solve_first_config.sh"
    }
  }
}

# Chapter 3 -----------------------------------------------------------------
resource "task" "init_and_plan" {
  description     = "Initialise the working directory and save a plan"
  success_message = "You have downloaded the AWS provider and produced a saved plan."

  config {
    target            = resource.container.workstation
    user              = "root"
    working_directory = variable.workspace_dir
    timeout           = "180s"

    environment = {
      AWS_ACCESS_KEY_ID     = resource.aws_account.lab.user.0.access_key_id
      AWS_SECRET_ACCESS_KEY = resource.aws_account.lab.user.0.secret_access_key
      AWS_DEFAULT_REGION    = variable.aws_region
      AWS_PAGER             = ""
      WORKSPACE             = variable.workspace_dir
      LAB_SUFFIX            = resource.random_id.lab.hex
    }
  }

  condition "initialised" {
    description = "Run terraform init"

    check {
      script          = "scripts/task/init_and_plan/check_init.sh"
      failure_message = "No .terraform directory or lock file yet. Run: terraform init"
    }

    solve {
      script = "scripts/task/init_and_plan/solve_init.sh"
    }
  }

  condition "plan_saved" {
    description = "Save a plan to a file called tfplan"

    check {
      script          = "scripts/task/init_and_plan/check_plan.sh"
      failure_message = "No usable tfplan found. Run: terraform plan -out=tfplan"
    }

    solve {
      script = "scripts/task/init_and_plan/solve_plan.sh"
    }
  }
}

# Chapter 4 -----------------------------------------------------------------
resource "task" "apply_infra" {
  description     = "Apply your configuration and verify the bucket exists"
  success_message = "Your first real AWS resource, created by Terraform."

  config {
    target            = resource.container.workstation
    user              = "root"
    working_directory = variable.workspace_dir
    timeout           = "180s"

    environment = {
      AWS_ACCESS_KEY_ID     = resource.aws_account.lab.user.0.access_key_id
      AWS_SECRET_ACCESS_KEY = resource.aws_account.lab.user.0.secret_access_key
      AWS_DEFAULT_REGION    = variable.aws_region
      AWS_PAGER             = ""
      WORKSPACE             = variable.workspace_dir
      LAB_SUFFIX            = resource.random_id.lab.hex
    }
  }

  condition "state_has_bucket" {
    description = "Terraform state tracks the bucket"

    check {
      script          = "scripts/task/apply_infra/check_state.sh"
      failure_message = "aws_s3_bucket.lab is not in state yet. Run: terraform apply"
    }

    solve {
      script = "scripts/task/apply_infra/solve_apply.sh"
    }
  }

  condition "bucket_live_in_aws" {
    description = "The bucket really exists in AWS"

    check {
      script          = "scripts/task/apply_infra/check_bucket_live.sh"
      failure_message = "The bucket in your state could not be found in AWS. Check terraform apply output for errors."
    }

    solve {
      script = "scripts/task/apply_infra/solve_apply.sh"
    }
  }
}

# Chapter 5 -----------------------------------------------------------------
resource "task" "variables_and_outputs" {
  description     = "Refactor with variables and outputs, then add a VPC"
  success_message = "Your configuration is now parameterised and exposes outputs."

  config {
    target            = resource.container.workstation
    user              = "root"
    working_directory = variable.workspace_dir
    timeout           = "240s"

    environment = {
      AWS_ACCESS_KEY_ID     = resource.aws_account.lab.user.0.access_key_id
      AWS_SECRET_ACCESS_KEY = resource.aws_account.lab.user.0.secret_access_key
      AWS_DEFAULT_REGION    = variable.aws_region
      AWS_PAGER             = ""
      WORKSPACE             = variable.workspace_dir
      LAB_SUFFIX            = resource.random_id.lab.hex
    }
  }

  condition "variables_file" {
    description = "Declare input variables in variables.tf"

    check {
      script          = "scripts/task/variables_and_outputs/check_variables.sh"
      failure_message = "variables.tf must declare variables named aws_region, bucket_suffix and environment."
    }

    solve {
      script = "scripts/task/variables_and_outputs/solve_refactor.sh"
    }
  }

  condition "network_applied" {
    description = "Add and apply a VPC and subnet"

    check {
      script          = "scripts/task/variables_and_outputs/check_network.sh"
      failure_message = "aws_vpc.lab and aws_subnet.lab are not both in state. Add them to network.tf and run terraform apply."
    }

    solve {
      script = "scripts/task/variables_and_outputs/solve_refactor.sh"
    }
  }

  condition "outputs_available" {
    description = "Expose bucket_name and vpc_id as outputs"

    check {
      script          = "scripts/task/variables_and_outputs/check_outputs.sh"
      failure_message = "terraform output must return non-empty bucket_name and vpc_id values. Declare them in outputs.tf and re-apply."
    }

    solve {
      script = "scripts/task/variables_and_outputs/solve_refactor.sh"
    }
  }
}

# Chapter 6 -----------------------------------------------------------------
resource "task" "remote_state" {
  description     = "Move your state into the shared S3 backend"
  success_message = "State is now stored remotely in S3, versioned and shareable."

  config {
    target            = resource.container.workstation
    user              = "root"
    working_directory = variable.workspace_dir
    timeout           = "240s"

    environment = {
      AWS_ACCESS_KEY_ID     = resource.aws_account.lab.user.0.access_key_id
      AWS_SECRET_ACCESS_KEY = resource.aws_account.lab.user.0.secret_access_key
      AWS_DEFAULT_REGION    = variable.aws_region
      AWS_PAGER             = ""
      WORKSPACE             = variable.workspace_dir
      TF_STATE_BUCKET       = variable.enable_remote_state ? resource.terraform.state_backend.output.bucket_name : ""
    }
  }

  condition "backend_configured" {
    description = "Declare an S3 backend in backend.tf"

    check {
      script          = "scripts/task/remote_state/check_backend_config.sh"
      failure_message = "backend.tf must contain a backend \"s3\" block pointing at the bucket in $TF_STATE_BUCKET with a key and region."
    }

    solve {
      script = "scripts/task/remote_state/solve_remote_state.sh"
    }
  }

  condition "state_migrated" {
    description = "Migrate local state to the S3 backend"

    check {
      script          = "scripts/task/remote_state/check_state_migrated.sh"
      failure_message = "State has not been migrated. Run: terraform init -migrate-state -force-copy"
    }

    solve {
      script = "scripts/task/remote_state/solve_remote_state.sh"
    }
  }
}

# Chapter 7 -----------------------------------------------------------------
resource "task" "cleanup" {
  description     = "Destroy everything you created"
  success_message = "Clean slate. This is the habit that keeps cloud bills sane."

  config {
    target            = resource.container.workstation
    user              = "root"
    working_directory = variable.workspace_dir
    timeout           = "300s"

    environment = {
      AWS_ACCESS_KEY_ID     = resource.aws_account.lab.user.0.access_key_id
      AWS_SECRET_ACCESS_KEY = resource.aws_account.lab.user.0.secret_access_key
      AWS_DEFAULT_REGION    = variable.aws_region
      AWS_PAGER             = ""
      WORKSPACE             = variable.workspace_dir
    }
  }

  condition "everything_destroyed" {
    description = "Run terraform destroy and leave state empty"

    check {
      script          = "scripts/task/cleanup/check_destroyed.sh"
      failure_message = "Terraform state still tracks resources. Run: terraform destroy"
    }

    solve {
      script = "scripts/task/cleanup/solve_destroy.sh"
    }
  }
}

# ---------------------------------------------------------------------------
# sandbox.hcl
# Infrastructure for the lab: network, sandboxed AWS account, pre-provisioned
# remote state bucket, and the learner workstation.
# ---------------------------------------------------------------------------

# Private network that every sandbox resource attaches to.
resource "network" "main" {
  subnet = "10.0.200.0/24"
}

# Short random suffix so every learner gets globally unique S3 bucket names.
resource "random_id" "lab" {
  byte_length = 4
}

# ---------------------------------------------------------------------------
# Sandboxed AWS account
#
# Instruqt creates a throwaway AWS account per session. The "student" user is
# the identity the learner's Terraform runs as. The inline IAM policy grants
# exactly what the lab needs; the SCP is a hard ceiling that cannot be escaped
# even if the IAM policy is wrong.
# ---------------------------------------------------------------------------
resource "aws_account" "lab" {
  regions  = [variable.aws_region]
  services = ["ec2", "s3", "iam"]

  tags = {
    Environment = "Training"
    Lab         = variable.lab_tag
    ManagedBy   = "Instruqt"
  }

  # The validator requires at least one managed policy OR an inline IAM policy.
  # We set both: managed policies give the broad grants, and the inline policy
  # is kept for documentation of exactly what the lab needs. The SCP below is
  # the real ceiling.
  user "student" {
    managed_policies = [
      "arn:aws:iam::aws:policy/AmazonS3FullAccess",
      "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
      "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
    ]

    iam_policy = file("./files/policies/student-policy.json")
  }

  scp_policy = file("./files/policies/guardrails-scp.json")
}

# ---------------------------------------------------------------------------
# Pre-provisioned remote state backend
#
# This is the `terraform` sandbox utility doing author-side provisioning: it
# runs `terraform apply` on ./terraform/state-backend before the learner ever
# sees a terminal, then hands the bucket name to the workstation as an
# environment variable. Chapter 6 has the learner migrate their local state
# into this bucket.
#
# Set variable.enable_remote_state = false to skip it.
# ---------------------------------------------------------------------------
resource "terraform" "state_backend" {
  disabled = !variable.enable_remote_state

  source  = "./terraform/state-backend"
  version = variable.terraform_version

  network {
    id = resource.network.main.meta.id
  }

  environment = {
    AWS_ACCESS_KEY_ID     = resource.aws_account.lab.user[0].access_key_id
    AWS_SECRET_ACCESS_KEY = resource.aws_account.lab.user[0].secret_access_key
    AWS_DEFAULT_REGION    = variable.aws_region
    AWS_REGION            = variable.aws_region
  }

  variables = {
    region = variable.aws_region
    suffix = resource.random_id.lab.hex
    lab    = variable.lab_tag
  }
}

# Starter files are mounted read-only and copied into the workspace by the
# install script, so the learner always has a pristine copy to fall back on.
resource "copy" "starter_files" {
  source      = "./files/workspace/"
  destination = "./lab-files/"
  permissions = "0644"
}

# ---------------------------------------------------------------------------
# Learner workstation
# ---------------------------------------------------------------------------
resource "container" "workstation" {
  image {
    name = variable.workstation_image
  }

  # ubuntu images exit immediately without a TTY, so hold the container open.
  command = ["sleep", "infinity"]

  network {
    id = resource.network.main.meta.id
  }

  resources {
    cpu    = 2000
    memory = 2048
  }

  volume {
    source      = resource.copy.starter_files.destination
    destination = "/lab-files"
    type        = "bind"
    read_only   = true
  }

  environment = {
    # AWS credentials for the student user. Terraform and the AWS CLI both
    # pick these up automatically - no `aws configure` needed.
    AWS_ACCESS_KEY_ID     = resource.aws_account.lab.user[0].access_key_id
    AWS_SECRET_ACCESS_KEY = resource.aws_account.lab.user[0].secret_access_key
    AWS_DEFAULT_REGION    = variable.aws_region
    AWS_REGION            = variable.aws_region
    AWS_PAGER             = ""
    AWS_ACCOUNT_ID        = resource.aws_account.lab.account_id
    # Lab-specific values the instructions and check scripts rely on.
    LAB_SUFFIX      = resource.random_id.lab.hex
    LAB_BUCKET      = "tf-lab-${resource.random_id.lab.hex}"
    LAB_TAG         = variable.lab_tag
    TF_STATE_BUCKET = variable.enable_remote_state ? resource.terraform.state_backend.output.bucket_name : ""
    TF_VERSION      = variable.terraform_version
    WORKSPACE       = variable.workspace_dir
    DEBIAN_FRONTEND = "noninteractive"
  }
}

# Installs Terraform, the AWS CLI and helpers, then seeds the workspace.
resource "exec" "install_tooling" {
  target  = resource.container.workstation
  script  = "scripts/exec/install_tooling/script.sh"
  timeout = "600s"

  environment = {
    "TF_VERSION"      = variable.terraform_version
    "WORKSPACE"       = variable.workspace_dir
    "DEBIAN_FRONTEND" = "noninteractive"
  }
}

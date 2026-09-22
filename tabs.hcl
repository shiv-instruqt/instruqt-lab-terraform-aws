# ---------------------------------------------------------------------------
# tabs.hcl
# Everything the learner can see and click: terminal, code editor, credentials
# panel and the reference notes.
# ---------------------------------------------------------------------------

resource "terminal" "workstation" {
  target            = resource.container.workstation
  shell             = "/bin/bash"
  working_directory = variable.workspace_dir
}

# A second terminal is handy for watching state while a plan runs.
resource "terminal" "scratch" {
  target            = resource.container.workstation
  shell             = "/bin/bash"
  working_directory = variable.workspace_dir
}

resource "editor" "workspace" {
  workspace "terraform" {
    target    = resource.container.workstation
    directory = variable.workspace_dir
  }
}

# Renders the sandboxed AWS account's console sign-in details and access keys.
resource "cloud_credentials" "aws" {
  aws_account {
    target = resource.aws_account.lab
    users  = ["student"]
  }
}

resource "note" "cheatsheet" {
  file = "notes/terraform-cheatsheet.md"
}

resource "note" "troubleshooting" {
  file = "notes/troubleshooting.md"
}

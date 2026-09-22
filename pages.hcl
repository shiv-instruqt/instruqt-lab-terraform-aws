# ---------------------------------------------------------------------------
# pages.hcl
# Each page points at a markdown file and maps activity ids to task resources.
# The key in `activities` is what you reference in markdown, e.g.
#   <instruqt-task id="verify_environment"></instruqt-task>
# ---------------------------------------------------------------------------

resource "page" "welcome" {
  title = "Welcome & Environment Check"
  file  = "instructions/01-welcome.md"

  activities = {
    verify_environment = resource.task.verify_environment
  }
}

resource "page" "first_config" {
  title = "Your First Configuration"
  file  = "instructions/02-first-configuration.md"

  activities = {
    first_config = resource.task.first_config
  }
}

resource "page" "init_and_plan" {
  title = "Init & Plan"
  file  = "instructions/03-init-and-plan.md"

  activities = {
    init_and_plan = resource.task.init_and_plan
  }
}

resource "page" "apply" {
  title = "Apply & Verify"
  file  = "instructions/04-apply.md"

  activities = {
    apply_infra = resource.task.apply_infra
  }
}

resource "page" "variables_and_outputs" {
  title = "Variables, Outputs & a VPC"
  file  = "instructions/05-variables-and-outputs.md"

  activities = {
    variables_and_outputs = resource.task.variables_and_outputs
  }
}

resource "page" "remote_state" {
  title = "Remote State on S3"
  file  = "instructions/06-remote-state.md"

  activities = {
    remote_state = resource.task.remote_state
  }
}

resource "page" "cleanup" {
  title = "Destroy & Wrap-Up"
  file  = "instructions/07-cleanup.md"

  activities = {
    cleanup = resource.task.cleanup
  }
}

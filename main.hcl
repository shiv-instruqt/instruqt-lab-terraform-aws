# ---------------------------------------------------------------------------
# main.hcl
# Lab metadata, settings and the chapter/page structure.
# ---------------------------------------------------------------------------

resource "lab" "terraform_aws_fundamentals" {
  title       = "Terraform on AWS: From Zero to Apply"
  description = "Write Terraform from scratch and use it to create real AWS infrastructure. You will declare a provider, run init, read a plan, apply an S3 bucket and a VPC, refactor with variables and outputs, move state to an S3 backend, and destroy it all cleanly."

  layout = resource.layout.workbench

  settings {
    theme = "modern-dark"

    timelimit {
      duration   = "2h"
      extend     = "30m"
      show_timer = true
    }

    idle {
      enabled      = true
      timeout      = "20m"
      show_warning = true
    }

    controls {
      show_stop = true
    }
  }

  content {
    title = "Terraform on AWS"

    chapter "getting_started" {
      title  = "Getting Started"
      layout = resource.layout.reading

      page "welcome" {
        reference = resource.page.welcome
      }
    }

    chapter "authoring" {
      title = "Writing Terraform"

      page "first_config" {
        reference = resource.page.first_config
      }

      page "init_and_plan" {
        reference = resource.page.init_and_plan
      }
    }

    chapter "provisioning" {
      title = "Creating Infrastructure"

      page "apply" {
        reference = resource.page.apply
      }

      page "variables_and_outputs" {
        reference = resource.page.variables_and_outputs
      }
    }

    chapter "state_and_cleanup" {
      title = "State & Cleanup"

      page "remote_state" {
        reference = resource.page.remote_state
      }

      page "cleanup" {
        layout    = resource.layout.reading
        reference = resource.page.cleanup
      }
    }
  }
}

# ---------------------------------------------------------------------------
# layouts.hcl
# Layouts are inherited most-specific-wins: page > chapter > lab.
# ---------------------------------------------------------------------------

# Default working layout: instructions on the left, terminal + editor on the
# right, with credentials and reference notes docked underneath.
resource "layout" "workbench" {
  column {
    width = "38"

    instructions {
      title = "Instructions"
    }
  }

  column {
    width = "62"

    row {
      height = "68"

      tab "terminal" {
        title  = "Terminal"
        target = resource.terminal.workstation
        active = true
      }

      tab "editor" {
        title  = "Code Editor"
        target = resource.editor.workspace
      }

      tab "scratch" {
        title  = "Terminal 2"
        target = resource.terminal.scratch
      }
    }

    row {
      height = "32"

      tab "cheatsheet" {
        title  = "Cheat Sheet"
        target = resource.note.cheatsheet
        active = true
      }

      tab "credentials" {
        title  = "AWS Credentials"
        target = resource.cloud_credentials.aws
      }

      tab "troubleshooting" {
        title  = "Troubleshooting"
        target = resource.note.troubleshooting
      }
    }
  }
}

# Reading-heavy layout for the welcome and wrap-up pages: more room for prose,
# terminal still available.
resource "layout" "reading" {
  column {
    width = "55"

    instructions {
      title = "Instructions"
    }
  }

  column {
    width = "45"

    tab "terminal" {
      title  = "Terminal"
      target = resource.terminal.workstation
      active = true
    }

    tab "credentials" {
      title  = "AWS Credentials"
      target = resource.cloud_credentials.aws
    }

    tab "cheatsheet" {
      title  = "Cheat Sheet"
      target = resource.note.cheatsheet
    }
  }
}

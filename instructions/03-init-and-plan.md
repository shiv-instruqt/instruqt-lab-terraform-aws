# Init and plan

You have a configuration. Terraform cannot do anything with it yet, because it
does not have the AWS provider plugin on disk.

## terraform init

`init` prepares a working directory. It reads your `required_providers`,
downloads matching plugins from the registry, and records exactly which
versions it picked.

```bash,run
terraform init
```

Two things appeared:

| Path | What it is |
|------|------------|
| `.terraform/` | The downloaded provider binaries. Large, disposable, never committed. |
| `.terraform.lock.hcl` | The exact provider versions and their checksums. Small, **always** committed. |

The lock file is the part people get wrong. It is what makes your colleague's
`terraform init` produce the same plugin as yours. Commit it.

```bash,run
ls -la && cat .terraform.lock.hcl
```

## terraform plan

`plan` is Terraform's dry run. It reads your configuration, refreshes what it
knows about the real world, and prints the difference.

```bash,run
terraform plan
```

Read the output carefully. The important line is near the bottom:

```
Plan: 1 to add, 0 to change, 0 to destroy.
```

Each resource is shown with a symbol:

| Symbol | Meaning |
|--------|---------|
| `+` | will be created |
| `-` | will be destroyed |
| `~` | will be updated in place |
| `-/+` | will be destroyed and recreated |

That last one is the one to watch for. Some arguments cannot be changed on a
live resource, so Terraform replaces it. On an S3 bucket that is harmless; on
a production database it is a very bad afternoon. Terraform always tells you
which argument forced the replacement.

Values shown as `(known after apply)` are ones AWS assigns, like the bucket's
ARN. Terraform cannot know them until the resource exists.

## Save the plan

A plan printed to the screen is a suggestion. A plan saved to a file is a
contract - applying it does exactly what it showed, even if someone else
changes the config in between. This is what CI pipelines do.

```bash,run
terraform plan -out=tfplan
```

Inspect it as JSON, which is how automation reads plans:

```bash,run
terraform show -json tfplan | jq '.resource_changes[] | {address, actions: .change.actions}'
```

<instruqt-task id="init_and_plan"></instruqt-task>

> **Never commit `tfplan`.** It can contain values from your state, including
> secrets. The `.gitignore` in your workspace already excludes it.

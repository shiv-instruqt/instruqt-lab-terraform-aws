# Your Terraform workspace

Everything you write in this lab lives here, in `/workspace`.

| Path | What it is |
|------|------------|
| `main.tf` | Where you start writing. Empty except for hints. |
| `checks/` | Chapter 1 asks you to save some command output here. |
| `.gitignore` | A sensible Terraform ignore file, for when you do this for real. |

## Values that are already set for you

These environment variables exist in every terminal:

| Variable | Meaning |
|----------|---------|
| `$LAB_SUFFIX` | A short random string unique to your session. |
| `$LAB_BUCKET` | The S3 bucket name to use: `tf-lab-<suffix>`. |
| `$TF_STATE_BUCKET` | Pre-made bucket for remote state (Chapter 6). |
| `$AWS_REGION` | The only region you are allowed to use. |
| `$AWS_ACCOUNT_ID` | Your throwaway AWS account. |

AWS credentials are already in the environment, so `terraform` and `aws` just
work. You never need to run `aws configure`.

## Handy aliases

`tf`, `tfi`, `tfp`, `tfa`, `tfd` map to `terraform`, `init`, `plan`, `apply`
and `destroy`.

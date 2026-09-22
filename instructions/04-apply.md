# Apply and verify

Time to create something.

## terraform apply

Apply the plan you saved. Because the plan file already says what will happen,
Terraform does not ask for confirmation:

```bash,run
terraform apply tfplan
```

Watch the output. Terraform prints each resource as it works, then a summary:

```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Running `apply` without a plan file is the more common day-to-day workflow -
it plans, shows you the result, and waits for you to type `yes`.

## State

Terraform now knows something it did not know a minute ago: which real AWS
object corresponds to `aws_s3_bucket.lab`. That mapping lives in
`terraform.tfstate`.

```bash,run
terraform state list
```

```bash,run
terraform state show aws_s3_bucket.lab
```

State is the single most important file in Terraform, and the most dangerous.
It is how Terraform knows the difference between "create this" and "you
already have this". Lose it and Terraform will cheerfully try to create
everything again.

It is also plain JSON, and it contains every attribute of every resource -
including any passwords or keys. **State is a secret.** Chapter 6 moves it
somewhere safer than your laptop.

## Verify independently

Terraform says the bucket exists. Trust, but verify - ask AWS directly:

```bash,run
aws s3 ls | grep "$LAB_SUFFIX"
```

```bash,run
aws s3api get-bucket-tagging --bucket "$LAB_BUCKET"
```

You can also open the **AWS Credentials** tab below the terminal and sign in
to the console with those details to see the bucket in the web UI.

## The idempotency test

Run the plan again:

```bash,run
terraform plan
```

```
No changes. Your infrastructure matches the configuration.
```

This is the whole point. Terraform describes a desired *state*, not a sequence
of steps. Running it twice does not create two buckets. That property is what
makes it safe to run from CI on every merge.

<instruqt-task id="apply_infra"></instruqt-task>

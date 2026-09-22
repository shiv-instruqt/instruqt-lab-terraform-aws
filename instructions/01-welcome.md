# Terraform on AWS

Over the next hour or so you are going to write Terraform from scratch and use
it to create real infrastructure in a real AWS account.

Not a simulator. A throwaway AWS account that belongs to you for the length of
this session, and which is deleted the moment you finish.

## What you will build

By the end you will have written a configuration that creates an S3 bucket, a
VPC and a subnet, refactored it to use variables and outputs, moved its state
into an S3 backend, and torn the whole thing down again.

More importantly you will understand the loop that every Terraform user runs
hundreds of times a day: **write, init, plan, apply**.

## Your environment

The terminal on the right is a Linux workstation with Terraform and the AWS
CLI already installed. Credentials for your sandbox AWS account are already in
the environment, so you never need to run `aws configure`.

A few values are set for you:

```bash,run
echo "Region:     $AWS_REGION"
echo "Account:    $AWS_ACCOUNT_ID"
echo "Suffix:     $LAB_SUFFIX"
echo "Bucket:     $LAB_BUCKET"
```

`$LAB_SUFFIX` is a random string unique to your session. S3 bucket names are
globally unique across all of AWS, so you will append it to anything you
create.

## Prove the tools work

Two commands, and save the output of each. The first shows which Terraform you
are running:

```bash,run
mkdir -p checks && terraform version | tee checks/terraform.txt
```

The second asks AWS "who am I?" - it is the fastest way to confirm your
credentials are valid before you waste time debugging a config:

```bash,run
aws sts get-caller-identity | tee checks/identity.json
```

If that second command returns an account number, you are ready.

<instruqt-task id="verify_environment"></instruqt-task>

> **A note on the Cheat Sheet tab.** Everything you need is in the
> instructions, but the tab below the terminal has a one-page command
> reference if you would rather not scroll back.

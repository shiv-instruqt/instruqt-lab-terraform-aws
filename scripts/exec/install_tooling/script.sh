#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Provisions the learner workstation: Terraform, AWS CLI v2, helper tools and
# a seeded workspace. Runs once during sandbox creation.
# ---------------------------------------------------------------------------
set -euo pipefail

TF_VERSION="${TF_VERSION:-1.9.8}"
WORKSPACE="${WORKSPACE:-/workspace}"
export DEBIAN_FRONTEND=noninteractive

log() { echo "[setup] $*"; }

# --- base packages ---------------------------------------------------------
log "installing base packages"
apt-get update -qq
apt-get install -y -qq --no-install-recommends \
  ca-certificates curl unzip jq git tree less vim nano \
  bash-completion procps groff

# --- detect architecture ---------------------------------------------------
case "$(uname -m)" in
  x86_64)        ARCH="amd64"; AWS_ARCH="x86_64"  ;;
  aarch64|arm64) ARCH="arm64"; AWS_ARCH="aarch64" ;;
  *) echo "[setup] unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

# --- terraform -------------------------------------------------------------
if ! command -v terraform >/dev/null 2>&1; then
  log "installing terraform ${TF_VERSION} (${ARCH})"
  tmp="$(mktemp -d)"
  curl -fsSL -o "${tmp}/terraform.zip" \
    "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${ARCH}.zip"
  unzip -q -o "${tmp}/terraform.zip" -d /usr/local/bin
  chmod 0755 /usr/local/bin/terraform
  rm -rf "${tmp}"
else
  log "terraform already present"
fi

# --- aws cli v2 ------------------------------------------------------------
if ! command -v aws >/dev/null 2>&1; then
  log "installing aws cli v2 (${AWS_ARCH})"
  tmp="$(mktemp -d)"
  curl -fsSL -o "${tmp}/awscliv2.zip" \
    "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip"
  unzip -q "${tmp}/awscliv2.zip" -d "${tmp}"
  "${tmp}/aws/install" --update >/dev/null
  rm -rf "${tmp}"
else
  log "aws cli already present"
fi

# --- seed the workspace ----------------------------------------------------
log "seeding workspace at ${WORKSPACE}"
mkdir -p "${WORKSPACE}/checks"

if [ -d /lab-files ]; then
  # -n so re-runs never clobber the learner's own edits
  cp -rn /lab-files/. "${WORKSPACE}/" 2>/dev/null || true
fi

if [ -f "${WORKSPACE}/gitignore.example" ]; then
  mv -n "${WORKSPACE}/gitignore.example" "${WORKSPACE}/.gitignore" || true
fi

chmod -R u+rwX "${WORKSPACE}"

# --- shell experience ------------------------------------------------------
cat > /etc/profile.d/99-lab.sh <<'PROFILE'
export AWS_PAGER=""
export PS1='\[\e[1;36m\]terraform-lab\[\e[0m\]:\[\e[1;33m\]\w\[\e[0m\]$ '
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias ll='ls -alF'
PROFILE
chmod 0644 /etc/profile.d/99-lab.sh

if ! grep -q '99-lab.sh' /root/.bashrc 2>/dev/null; then
  cat >> /root/.bashrc <<BASHRC

# --- lab defaults ---
[ -f /etc/profile.d/99-lab.sh ] && . /etc/profile.d/99-lab.sh
[ -d ${WORKSPACE} ] && cd ${WORKSPACE}
BASHRC
fi

terraform -install-autocomplete >/dev/null 2>&1 || true

# --- verify ----------------------------------------------------------------
log "verifying installation"
terraform version
aws --version
log "workstation ready"

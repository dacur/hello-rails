#!/usr/bin/env bash
set -euo pipefail

# Always run from repo root
cd "$(dirname "$0")"

# --- Init Terraform so destroy can run ---
cd infra
terraform init -input=false

# --- Empty the ECR repo so Terraform can delete it ---
# (If you add force_delete in Terraform later, this section becomes unnecessary.)
ECR_URL="$(terraform output -raw repository_url || true)"
if [ -n "${ECR_URL:-}" ]; then
  REPO_NAME="$(basename "$ECR_URL")"
  echo "Emptying ECR repo: $REPO_NAME"

  # Delete all images in batches until empty (handles pagination implicitly)
  while true; do
    IDS_JSON="$(aws ecr list-images --repository-name "$REPO_NAME" --query 'imageIds' --output json)"
    if [ "$IDS_JSON" = "[]" ]; then
      echo "ECR repo is empty."
      break
    fi
    aws ecr batch-delete-image --repository-name "$REPO_NAME" --image-ids "$IDS_JSON" >/dev/null
    echo "Deleted a batch of images..."
  done
fi

# --- Destroy all Terraform-managed resources ---
terraform destroy -auto-approve

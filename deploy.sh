#!/usr/bin/env bash
set -x
set -euo pipefail

# --- Terraform (safe to re-run) ---
cd infra
terraform init -input=false
terraform apply -auto-approve -input=false
cd ..

# --- Outputs ---
ECR="$(cd infra && terraform output -raw repository_url)"
CLUSTER="$(cd infra && terraform output -raw cluster_name)"
SERVICE="$(cd infra && terraform output -raw service_name)"
ALB_URL="$(cd infra && terraform output -raw alb_dns_name)"
REPO_NAME="$(basename "$ECR")"

# --- Identify current source version ---
SHA="$(git rev-parse HEAD 2>/dev/null || echo "no-git-$(date +%s)")"

# --- If this SHA already exists in ECR, skip build/push/redeploy ---
if aws ecr describe-images --repository-name "$REPO_NAME" --image-ids imageTag="$SHA" >/dev/null 2>&1; then
  echo "✅ Image $REPO_NAME:$SHA already in ECR. Skipping build/push/redeploy."
  echo "🚀 App: http://$ALB_URL"
  exit 0
fi

# --- ECR login ---
aws ecr get-login-password | docker login --username AWS --password-stdin "$(dirname "$ECR")"

# --- Build & push (ARM64 for M1); tag with SHA and latest ---
docker buildx create --use --name xbuilder >/dev/null 2>&1 || true
docker buildx build \
  --platform=linux/arm64 \
  -t "$ECR:$SHA" \
  -t "$ECR:latest" \
  --push .

# --- Redeploy only when a new image was pushed ---
aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" --force-new-deployment
aws ecs wait services-stable --cluster "$CLUSTER" --services "$SERVICE"

echo "🚀 Deployed $REPO_NAME:$SHA"
echo "🔗 http://$ALB_URL"

# Hello Rails (Docker + Terraform + AWS ECS) 🚃

This is a minimal Ruby on Rails app containerized with Docker and deployed to AWS ECS Fargate using Terraform. A GitHub Actions workflow builds and deploys the app automatically whenever code is pushed to `main`.

**⚠️ NOTE:** Before starting, be sure you understand what this code is doing because **you WILL incur AWS charges**! 💰  

Always run `./destroy.sh` when you are finished, and log into your AWS account to double-check that everything is cleaned up.  

🚨 This project is provided **as-is, with no warranty or responsibility** for any AWS costs or resource usage you may incur. 🚨

---

## Project Overview ⛰️
- **Rails**: Simple "Hello World" controller/view (no database).
- **Docker**: Rails app containerized and ready for deployment.
- **Terraform**: Provisions AWS resources:
  - ECR repository for Docker images
  - ECS Fargate cluster + service
  - Application Load Balancer (ALB)
  - Security groups and CloudWatch logging
- **GitHub Actions**: CI/CD workflow that:
  - Builds an ARM64 image (compatible with Apple M1/M2)
  - Pushes to Amazon ECR
  - Forces a new ECS service deployment
  - Skips redeploy if the same commit image already exists (idempotent)

---

## Requirements 🛠️
- macOS (tested on M1/M2 with Docker Desktop)
- [Ruby on Rails](https://rubyonrails.org/)
- [Docker](https://docs.docker.com/get-docker/)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/)
- An AWS account with sufficient IAM permissions
- A GitHub repository with Actions enabled

---

## Setup & Deployment 👨‍💻

### Local Run (no AWS/GitHub needed) 🐳
You can run the app locally with Docker:

```bash
docker build -t hello-rails:local .
docker run --rm -p 3000:3000 hello-rails:local
```

Then open [http://localhost:3000](http://localhost:3000) in your browser.

---

### Deploy to AWS (via GitHub Actions) 🤖
When you push to `main`, GitHub Actions will build and deploy the app to AWS ECS Fargate.  
For this to work, you must first set the required repository variables and secrets in GitHub:

- **Repository Variables** (from Terraform outputs): 📝
  - `ECR_REPO` ← `repository_url`  
  - `ECS_CLUSTER` ← `cluster_name`  
  - `ECS_SERVICE` ← `service_name`

- **Secrets**: 🤫
  - `AWS_ACCESS_KEY_ID`  
  - `AWS_SECRET_ACCESS_KEY`

Once configured, every push to `main` will automatically trigger a build & deploy.  
The app will be available at the `alb_dns_name` output URL.

---

## Helper Scripts 🤝

- **Deploy:** 🚀 
  ```bash
  ./deploy.sh
  ```  
  Builds, pushes, and redeploys the app.

- **Destroy:** 💣
  ```bash
  ./destroy.sh
  ```  
  Tears down all AWS infrastructure (force deletes ECR images).

---

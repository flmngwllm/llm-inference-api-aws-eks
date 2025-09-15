This repository provides a complete, end-to-end solution for deploying a scalable Large Language Model (LLM) inference API on the Amazon Web Services (AWS) Elastic Kubernetes Service (EKS). The entire infrastructure is provisioned using Terraform, and the deployment is automated with GitHub Actions.

The project includes:

A FastAPI application to serve LLM inferences using a CPU-optimized Hugging Face model.
Terraform configurations for all required AWS infrastructure, including VPC, EKS, ECR, S3, and CloudFront.
A Helm chart for streamlined deployment of the application onto the EK S cluster.
A simple React frontend to interact with the deployed API.
GitHub Actions workflows for automated CI/CD pipelines to build, test, and deploy the infrastructure and application.
Architecture Overview
The system is composed of several key components that work together to provide a robust and scalable inference service.

Image placeholder: A diagram showing the flow from a user to CloudFront, then to either the S3 bucket for the frontend or the ALB/EKS cluster for API requests.

CI/CD Pipeline (GitHub Actions):

infra.yml: Provisions all AWS resources using Terraform.
deploy.yml: Builds the API's Docker image, pushes it to Amazon ECR, and deploys it to the EKS cluster using Helm.
frontend-deploy.yml: Builds the React UI and deploys it to an S3 bucket.
AWS Infrastructure (Terraform):

Networking: A custom VPC with public and private subnets, an Internet Gateway, and a NAT Gateway.
Compute: An EKS cluster with a managed node group running in the private subnets.
Container Registry: An ECR repository to store the llm-api Docker image.
Storage: Two S3 buckets: one for Terraform state (llm-inference-api-terraform-state) and another for the static frontend assets (llm-inference-api-frontend). A third bucket is created for CI artifacts.
Content Delivery: A CloudFront distribution serves the static frontend from S3 and acts as a reverse proxy, forwarding API requests (/api/*) to the Application Load Balancer.
Security: IAM roles and policies configured with least-privilege principles, using OIDC for secure, keyless authentication from GitHub Actions.
Application Stack:

Backend API (llm-api): A Python FastAPI application that exposes a /api/generate endpoint. It uses the transformers library to load and run a CPU-friendly model (default: Qwen/Qwen2.5-0.5B-Instruct).
Frontend UI (llm-api-ui): A simple React + Vite application providing a textbox to send prompts to the backend API and display the results.
Project Structure
.
├── .github/workflows/      # GitHub Actions for CI/CD
│   ├── deploy.yml          # Builds/deploys the API to EKS
│   ├── frontend-deploy.yml # Builds/deploys the React UI to S3/CloudFront
│   └── infra.yml           # Provisions AWS infrastructure with Terraform
├── backend/                # Terraform for bootstrapping (state bucket, GHA role)
├── llm-api/                # Source code for the backend service
│   ├── app/                # FastAPI application source (main.py, model.py)
│   ├── llm-api-helm-chart/ # Helm chart for Kubernetes deployment
│   ├── llm-api-ui/         # React frontend source code
│   └── Dockerfile          # Dockerfile for the API
└── terraform/              # Main Terraform configuration for EKS, VPC, etc.
Setup and Deployment
This project is designed to be deployed automatically via GitHub Actions.

Prerequisites
An AWS account.
An AWS IAM User or Role with sufficient permissions to create the resources defined in the Terraform files.
A GitHub repository with Actions enabled.
The following tools installed locally for any manual interaction: AWS CLI, Terraform, kubectl, helm.
1. Bootstrap the Backend
The backend directory contains Terraform code to create the foundational resources required for the CI/CD pipeline:

An S3 bucket to store Terraform state.
A DynamoDB table for Terraform state locking.
An IAM role that GitHub Actions will assume to deploy resources.
You must apply this configuration manually once before the automated workflows can run.

Navigate to the backend directory:

cd backend
Initialize Terraform. For the very first run, you may need to comment out the backend "s3" block in main.tf to use a local state file, then uncomment it after the S3 bucket is created.

Apply the Terraform configuration. You will need to provide your AWS Account ID.

terraform init -upgrade
terraform apply -var="account_id=YOUR_AWS_ACCOUNT_ID"
2. Configure GitHub Secrets
After bootstrapping, a role named llm-inference-api-github-actions-role will be created in your AWS account.

In your GitHub repository, go to Settings > Secrets and variables > Actions.
Create a new repository secret named ACTIONS_ROLE_ARN.
Set its value to the ARN of the IAM role created in the previous step. You can get this from the IAM console or by querying the role:
aws iam get-role --role-name llm-inference-api-github-actions-role --query "Role.Arn" --output text
3. Deploy via GitHub Actions
With the bootstrap infrastructure and GitHub secret in place, the CI/CD pipelines will run automatically.

Push to main: A push to the terraform/ directory on the main branch will trigger the infra.yml workflow.

This workflow runs terraform apply to create the VPC, EKS cluster, ECR repository, and all other AWS resources.
It saves important Terraform outputs (like bucket names and CloudFront IDs) to a CI artifacts S3 bucket for subsequent jobs.
Infrastructure Workflow Completion: Upon successful completion of the infra.yml workflow, two other workflows are triggered:

deploy.yml: This workflow builds the llm-api Docker image, pushes it to ECR, installs the AWS Load Balancer Controller on the cluster, and deploys the API using its Helm chart. It determines the public URL of the ALB and saves it for the frontend.
frontend-deploy.yml: This workflow builds the React application, injecting the API's public URL as an environment variable. It then syncs the static files to the frontend S3 bucket and creates a CloudFront invalidation to ensure users get the latest version.
You can also trigger these workflows manually from the "Actions" tab in your GitHub repository.

4. Access the Application
Once all workflows have completed successfully, the application will be available at the CloudFront distribution's domain name. You can find this URL in the Terraform output of the infra job.

# From the terraform/ directory after applying
terraform output -raw cloudfront_domain_name
Configuration
LLM Model
The inference model can be configured via environment variables in llm-api/app/model.py. The key variables are:

MODEL_NAME: The Hugging Face model identifier (default: Qwen/Qwen2.5-0.5B-Instruct).
MAX_INPUT_TOKENS: Maximum tokens for the input prompt (default: 512).
MAX_NEW_TOKENS: Maximum new tokens to generate (default: 64).
To change these, you can rebuild the Docker image or modify the Helm deployment to pass these as environment variables to the container.

Kubernetes Resources
Application resources like the number of replicas, CPU/memory requests and limits, and autoscaling parameters can be configured in llm-api/llm-api-helm-chart/values.yaml.

Terraform
Major infrastructure settings, such as the AWS region, VPC CIDR blocks, and instance types, are defined as variables in terraform/variables.tf.

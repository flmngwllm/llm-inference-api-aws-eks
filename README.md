# LLM Inference API on AWS EKS

This repository provides a complete, end-to-end solution for deploying a scalable Large Language Model (LLM) inference API on the Amazon Web Services (AWS) Elastic Kubernetes Service (EKS). The entire infrastructure is provisioned using Terraform, and the deployment is automated with GitHub Actions.

---

## The project includes

- A FastAPI application to serve LLM inferences using a CPU-optimized Hugging Face model.  
- Terraform configurations for all required AWS infrastructure, including VPC, EKS, ECR, S3, and CloudFront.  
- A Helm chart for streamlined deployment of the application onto the EKS cluster.  
- A simple React frontend to interact with the deployed API.  
- GitHub Actions workflows for automated CI/CD pipelines to build, test, and deploy the infrastructure and application.  

---

## Architecture Overview

The system is composed of several key components that work together to provide a robust and scalable inference service.

### CI/CD Pipeline (GitHub Actions)

- **infra.yml**: Provisions all AWS resources using Terraform.  
- **deploy.yml**: Builds the API's Docker image, pushes it to Amazon ECR, and deploys it to the EKS cluster using Helm.  
- **frontend-deploy.yml**: Builds the React UI and deploys it to an S3 bucket.  

### AWS Infrastructure (Terraform)

- **Networking**: A custom VPC with public and private subnets, an Internet Gateway, and a NAT Gateway.  
- **Compute**: An EKS cluster with a managed node group running in the private subnets.  
- **Container Registry**: An ECR repository to store the llm-api Docker image.  
- **Storage**:  
  - S3 bucket for Terraform state (`llm-inference-api-terraform-state`)  
  - S3 bucket for static frontend assets (`llm-inference-api-frontend`)  
  - Third S3 bucket for CI artifacts  
- **Content Delivery**: A CloudFront distribution serves the static frontend from S3 and acts as a reverse proxy, forwarding API requests (`/api/*`) to the Application Load Balancer.  
- **Security**: IAM roles and policies configured with least-privilege principles, using OIDC for secure, keyless authentication from GitHub Actions.  

### Application Stack

- **Backend API (`llm-api`)**: A Python FastAPI application that exposes a `/api/generate` endpoint. It uses the transformers library to load and run a CPU-friendly model (default: `Qwen/Qwen2.5-0.5B-Instruct`).  
- **Frontend UI (`llm-api-ui`)**: A simple React + Vite application providing a textbox to send prompts to the backend API and display the results.  

---

## Project Structure

```plaintext
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

# AWS Deployment Guide for Organica

This project is now ready for a full-scale AWS deployment. Follow these steps to get it live.

## 1. Install Required Tools

You must have these installed on your machine:

- **AWS CLI**: [Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- **Terraform**: [Install Guide](https://developer.hashicorp.com/terraform/downloads)
- **Docker Desktop**: (You already have this)

## 2. Configure AWS

Run this in your terminal to set your access keys:

```powershell
aws configure
```

## 3. Run the Auto-Deployer

I have created a script called `deploy_aws.ps1` that automates all the steps we discussed. Run it with your AWS Account ID:

```powershell
./deploy_aws.ps1 -AWS_ACCOUNT_ID 123456789012
```

## What this script does:

1.  **Terraform**: Creates the VPC, S3 bucket, CloudFront distribution, RDS Database, and EKS Cluster.
2.  **Docker**: Builds the Spring Boot backend and pushes it to AWS ECR.
3.  **React**: Builds the frontend and uploads it to the S3 bucket.
4.  **Kubernetes**: Deploys the backend to your new EKS cluster.

## Architecture

- **Frontend**: Hosted on S3 + CloudFront (HTTPS).
- **Backend**: Running on EKS (Kubernetes) with a Load Balancer.
- **Database**: Managed RDS MySQL (Automated backups/scaling).

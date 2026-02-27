param (
    [Parameter(Mandatory=$true)]
    [string]$AWS_ACCOUNT_ID,
    
    [Parameter(Mandatory=$false)]
    [string]$REGION = "us-east-1"
)

$ECR_REPO = "$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

Write-Host "--- Starting Organica AWS Deployment ---" -ForegroundColor Cyan

# 1. Infrastructure
Write-Host "`n[1/4] Initializing Infrastructure with Terraform..." -ForegroundColor Yellow
cd terraform
terraform init
terraform apply -auto-approve
cd ..

# 2. Backend to ECR
Write-Host "`n[2/4] Building and Pushing Backend Image..." -ForegroundColor Yellow
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REPO

docker build -t organica-backend ./Server
docker tag organica-backend:latest $ECR_REPO/organica-backend:latest
docker push $ECR_REPO/organica-backend:latest

# 3. Frontend to S3
Write-Host "`n[3/4] Building and Syncing Frontend..." -ForegroundColor Yellow
cd Client
npm install
npm run build
aws s3 sync build/ s3://organica-frontend-assets
cd ..

# 4. Kubernetes Deployment
Write-Host "`n[4/4] Updating EKS and Deploying Manifests..." -ForegroundColor Yellow
aws eks update-kubeconfig --region $REGION --name organica-cluster

# Update image in yaml before applying
(Get-Content k8s/aws-backend.yaml) -replace "<YOUR_AWS_ACCOUNT_ID>", $AWS_ACCOUNT_ID | Set-Content k8s/aws-backend.yaml
kubectl apply -f k8s/aws-backend.yaml

Write-Host "`n--- Deployment Task Complete! ---" -ForegroundColor Green
Write-Host "Check your CloudFront and LoadBalancer URLs in the AWS Console."

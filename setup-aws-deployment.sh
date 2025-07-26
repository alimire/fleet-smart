#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header "Fleet Smart AWS Deployment Setup"

# Check if required tools are installed
print_status "Checking prerequisites..."

if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install it first."
    print_status "Visit: https://developer.hashicorp.com/terraform/downloads"
    exit 1
fi

if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    print_status "Visit: https://aws.amazon.com/cli/"
    exit 1
fi

print_status "✅ Prerequisites check passed"

# Generate SSH key pair if it doesn't exist
if [ ! -f ~/.ssh/fleet-smart-key ]; then
    print_status "Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/fleet-smart-key -N ""
    chmod 600 ~/.ssh/fleet-smart-key
    chmod 644 ~/.ssh/fleet-smart-key.pub
    print_status "✅ SSH key pair generated"
else
    print_status "✅ SSH key pair already exists"
fi

# Read public key
PUBLIC_KEY=$(cat ~/.ssh/fleet-smart-key.pub)

# Create terraform.tfvars file
print_status "Creating Terraform variables file..."
cat > terraform/terraform.tfvars << EOF
aws_region = "us-east-1"
instance_type = "t3.medium"
public_key = "$PUBLIC_KEY"
EOF

print_status "✅ Terraform variables file created"

# Initialize and apply Terraform
print_status "Initializing Terraform..."
cd terraform
terraform init

print_status "Planning Terraform deployment..."
terraform plan

print_warning "This will create AWS resources that may incur costs."
read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Deployment cancelled"
    exit 0
fi

print_status "Applying Terraform configuration..."
terraform apply -auto-approve

# Get outputs
INSTANCE_IP=$(terraform output -raw instance_public_ip)
ODOO_URL=$(terraform output -raw odoo_url)
SSH_COMMAND=$(terraform output -raw ssh_command)

cd ..

print_header "Deployment Information"
print_status "🌐 Instance IP: $INSTANCE_IP"
print_status "🔗 Odoo URL: $ODOO_URL"
print_status "🔑 SSH Command: $SSH_COMMAND"

print_header "GitHub Secrets Setup"
print_status "Add these secrets to your GitHub repository:"
echo -e "${YELLOW}AWS_ACCESS_KEY_ID${NC}: Your AWS access key"
echo -e "${YELLOW}AWS_SECRET_ACCESS_KEY${NC}: Your AWS secret key"
echo -e "${YELLOW}AWS_REGION${NC}: us-east-1"
echo -e "${YELLOW}EC2_HOST${NC}: $INSTANCE_IP"
echo -e "${YELLOW}EC2_USER${NC}: ubuntu"
echo -e "${YELLOW}EC2_SSH_KEY${NC}: $(cat ~/.ssh/fleet-smart-key)"

print_header "Next Steps"
print_status "1. Add the GitHub secrets listed above to your repository"
print_status "2. Push your code to trigger the GitHub Action"
print_status "3. Wait for deployment to complete"
print_status "4. Access your Fleet Smart app at: $ODOO_URL"

print_status "🎉 AWS infrastructure setup completed!"
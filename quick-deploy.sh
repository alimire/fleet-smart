#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_header() {
    echo
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC} $(printf "%-60s" "$1") ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC}  $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC}  $1"
}

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml not found. Please run this script from the project root."
    exit 1
fi

print_header "Fleet Smart - Quick Deployment Setup"

echo -e "${BLUE}This script will help you deploy Fleet Smart to AWS EC2 with GitHub Actions.${NC}"
echo
echo "What this script does:"
echo "• Sets up AWS infrastructure with Terraform"
echo "• Configures GitHub repository secrets"
echo "• Provides deployment instructions"
echo

read -p "Do you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Setup cancelled"
    exit 0
fi

# Step 1: Check prerequisites
print_header "Step 1: Checking Prerequisites"

MISSING_TOOLS=()

if ! command -v terraform &> /dev/null; then
    MISSING_TOOLS+=("terraform")
fi

if ! command -v aws &> /dev/null; then
    MISSING_TOOLS+=("aws-cli")
fi

if ! command -v git &> /dev/null; then
    MISSING_TOOLS+=("git")
fi

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    print_error "Missing required tools: ${MISSING_TOOLS[*]}"
    echo
    echo "Please install the missing tools:"
    echo "• Terraform: https://developer.hashicorp.com/terraform/downloads"
    echo "• AWS CLI: https://aws.amazon.com/cli/"
    echo "• Git: https://git-scm.com/downloads"
    exit 1
fi

print_status "All prerequisites are installed"

# Step 2: AWS Configuration
print_header "Step 2: AWS Configuration"

if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS CLI is not configured"
    print_info "Please run: aws configure"
    print_info "You'll need your AWS Access Key ID and Secret Access Key"
    exit 1
fi

AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region || echo "us-east-1")

print_status "AWS configured for account: $AWS_ACCOUNT"
print_status "Using region: $AWS_REGION"

# Step 3: Generate SSH Keys
print_header "Step 3: SSH Key Generation"

SSH_KEY_PATH="$HOME/.ssh/fleet-smart-key"

if [ ! -f "$SSH_KEY_PATH" ]; then
    print_info "Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "fleet-smart-deployment"
    chmod 600 "$SSH_KEY_PATH"
    chmod 644 "$SSH_KEY_PATH.pub"
    print_status "SSH key pair generated at $SSH_KEY_PATH"
else
    print_status "SSH key pair already exists"
fi

# Step 4: Terraform Setup
print_header "Step 4: Infrastructure Setup"

PUBLIC_KEY=$(cat "$SSH_KEY_PATH.pub")

# Create terraform.tfvars
cat > terraform/terraform.tfvars << EOF
aws_region = "$AWS_REGION"
instance_type = "t3.medium"
public_key = "$PUBLIC_KEY"
EOF

print_status "Terraform variables configured"

# Initialize Terraform
cd terraform
print_info "Initializing Terraform..."
terraform init -upgrade

print_info "Planning infrastructure..."
terraform plan -out=tfplan

print_warning "This will create AWS resources that may incur costs (~$30-50/month for t3.medium)"
echo
echo "Resources to be created:"
echo "• EC2 instance (t3.medium)"
echo "• Security Group"
echo "• Elastic IP"
echo "• SSH Key Pair"
echo

read -p "Do you want to create the infrastructure? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Infrastructure creation cancelled"
    cd ..
    exit 0
fi

print_info "Creating infrastructure... (this may take 2-3 minutes)"
terraform apply tfplan

# Get outputs
INSTANCE_IP=$(terraform output -raw instance_public_ip)
INSTANCE_ID=$(terraform output -raw instance_id)
ODOO_URL=$(terraform output -raw odoo_url)

cd ..

print_status "Infrastructure created successfully!"
print_info "Instance IP: $INSTANCE_IP"
print_info "Instance ID: $INSTANCE_ID"

# Step 5: GitHub Setup
print_header "Step 5: GitHub Repository Setup"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_error "Not in a Git repository. Please initialize git first:"
    echo "  git init"
    echo "  git add ."
    echo "  git commit -m 'Initial commit'"
    echo "  git remote add origin <your-repo-url>"
    exit 1
fi

# Get repository URL
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [ -z "$REPO_URL" ]; then
    print_warning "No remote origin found"
    echo "Please add your GitHub repository:"
    echo "  git remote add origin https://github.com/username/repo.git"
    echo
    read -p "Enter your GitHub repository URL: " REPO_URL
    git remote add origin "$REPO_URL" 2>/dev/null || true
fi

print_status "Repository: $REPO_URL"

# Step 6: GitHub Secrets
print_header "Step 6: GitHub Secrets Configuration"

echo -e "${YELLOW}Please add these secrets to your GitHub repository:${NC}"
echo
echo "Go to: $REPO_URL/settings/secrets/actions"
echo
echo -e "${BLUE}Required secrets:${NC}"
echo "┌─────────────────────┬─────────────────────────────────────────────────────────┐"
echo "│ Secret Name         │ Value                                                   │"
echo "├─────────────────────┼─────────────────────────────────────────────────────────┤"
echo "│ AWS_ACCESS_KEY_ID   │ $(aws configure get aws_access_key_id)                 │"
echo "│ AWS_SECRET_ACCESS_KEY│ $(aws configure get aws_secret_access_key)             │"
echo "│ AWS_REGION          │ $AWS_REGION                                             │"
echo "│ EC2_HOST            │ $INSTANCE_IP                                            │"
echo "│ EC2_USER            │ ubuntu                                                  │"
echo "│ EC2_SSH_KEY         │ (contents of $SSH_KEY_PATH)                             │"
echo "└─────────────────────┴─────────────────────────────────────────────────────────┘"
echo

print_warning "For EC2_SSH_KEY, copy the ENTIRE contents of the private key file:"
echo "  cat $SSH_KEY_PATH"
echo

read -p "Press Enter when you've added all the GitHub secrets..."

# Step 7: Deploy
print_header "Step 7: Initial Deployment"

print_info "Committing and pushing code to trigger deployment..."

git add .
git commit -m "Add Fleet Smart with automated AWS deployment" || print_warning "Nothing to commit"
git push origin main || git push origin master

print_status "Code pushed! GitHub Actions deployment started."

# Step 8: Final Instructions
print_header "🎉 Setup Complete!"

echo -e "${GREEN}Your Fleet Smart deployment is now set up!${NC}"
echo
echo -e "${BLUE}What happens next:${NC}"
echo "1. GitHub Actions will deploy your app to EC2 (takes ~5-10 minutes)"
echo "2. Monitor progress at: $REPO_URL/actions"
echo "3. Once complete, access your app at: $ODOO_URL"
echo
echo -e "${BLUE}After deployment:${NC}"
echo "1. Go to $ODOO_URL"
echo "2. Create a new database"
echo "3. Install the 'Fleet Smart' app"
echo "4. Start managing your EV fleet!"
echo
echo -e "${BLUE}Useful commands:${NC}"
echo "• SSH to server: ssh -i $SSH_KEY_PATH ubuntu@$INSTANCE_IP"
echo "• View logs: ssh -i $SSH_KEY_PATH ubuntu@$INSTANCE_IP 'cd fleet-smart-app && sudo docker-compose logs'"
echo "• Restart app: ssh -i $SSH_KEY_PATH ubuntu@$INSTANCE_IP 'cd fleet-smart-app && sudo docker-compose restart'"
echo
echo -e "${YELLOW}💰 Cost Management:${NC}"
echo "• Monthly cost: ~$30-50 for t3.medium instance"
echo "• To destroy infrastructure: cd terraform && terraform destroy"
echo
echo -e "${GREEN}🚀 Happy fleet managing!${NC}"
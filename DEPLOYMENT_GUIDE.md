# Fleet Smart - Complete AWS Deployment Guide

## 🚀 What We've Built

A complete **Electric Vehicle Fleet Management System** with:

- **Custom Odoo 17 Application** for EV fleet management
- **Automated AWS EC2 Deployment** using GitHub Actions
- **Infrastructure as Code** with Terraform
- **Health Monitoring** with automatic recovery
- **Containerized Architecture** with Docker

## 📋 Quick Start (One-Command Deployment)

```bash
./quick-deploy.sh
```

This single script will:
1. ✅ Check all prerequisites
2. ✅ Set up AWS infrastructure
3. ✅ Configure GitHub secrets
4. ✅ Deploy your Fleet Smart app
5. ✅ Provide access URLs and monitoring commands

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Developer     │    │   GitHub        │    │   AWS EC2       │
│                 │    │                 │    │                 │
│ • Code Changes  │───▶│ • GitHub Actions│───▶│ • Docker        │
│ • Git Push      │    │ • Automated CI  │    │ • Odoo 17       │
│ • Monitoring    │    │ • Deployment    │    │ • PostgreSQL    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                               ┌─────────────────┐
                                               │   Monitoring    │
                                               │                 │
                                               │ • Health Checks │
                                               │ • Auto Recovery │
                                               │ • Telegram Alerts│
                                               └─────────────────┘
```

## 📁 Project Structure

```
fleet-smart-app/
├── 🐳 Docker Configuration
│   ├── Dockerfile                    # Odoo container
│   └── docker-compose.yml           # Multi-container setup
│
├── 🚗 Fleet Smart Application
│   └── addons/fleet_smart/
│       ├── models/                  # EV vehicle models
│       ├── views/                   # Web interface
│       ├── data/                    # Sample EV data
│       ├── security/                # Access controls
│       └── __manifest__.py          # App configuration
│
├── ☁️ AWS Infrastructure
│   └── terraform/
│       ├── main.tf                  # EC2, Security Groups, EIP
│       ├── variables.tf             # Configuration variables
│       └── outputs.tf               # Deployment info
│
├── 🤖 GitHub Actions
│   └── .github/workflows/
│       └── deploy.yml               # Automated deployment
│
├── 📊 Monitoring & Scripts
│   ├── health_monitor.sh            # Health monitoring
│   ├── notify_telegram.sh           # Telegram notifications
│   ├── scripts/deploy.sh            # Deployment script
│   └── quick-deploy.sh              # One-click setup
│
└── 📚 Documentation
    ├── README.md                    # Main documentation
    └── DEPLOYMENT_GUIDE.md          # This guide
```

## 🛠️ Manual Setup (Step by Step)

### Prerequisites

1. **Install Required Tools**:
   ```bash
   # Terraform
   brew install terraform  # macOS
   # or download from: https://developer.hashicorp.com/terraform/downloads
   
   # AWS CLI
   brew install awscli     # macOS
   # or download from: https://aws.amazon.com/cli/
   
   # Git (usually pre-installed)
   git --version
   ```

2. **Configure AWS**:
   ```bash
   aws configure
   # Enter your AWS Access Key ID
   # Enter your AWS Secret Access Key
   # Enter your preferred region (e.g., us-east-1)
   # Enter output format (json)
   ```

### Step 1: Infrastructure Setup

1. **Generate SSH Keys**:
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/fleet-smart-key -N ""
   ```

2. **Configure Terraform**:
   ```bash
   cd terraform
   cat > terraform.tfvars << EOF
   aws_region = "us-east-1"
   instance_type = "t3.medium"
   public_key = "$(cat ~/.ssh/fleet-smart-key.pub)"
   EOF
   ```

3. **Deploy Infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Get Instance IP**:
   ```bash
   INSTANCE_IP=$(terraform output -raw instance_public_ip)
   echo "Instance IP: $INSTANCE_IP"
   ```

### Step 2: GitHub Repository Setup

1. **Initialize Git Repository**:
   ```bash
   git init
   git add .
   git commit -m "Initial Fleet Smart commit"
   git remote add origin https://github.com/yourusername/fleet-smart-app.git
   git push -u origin main
   ```

2. **Add GitHub Secrets**:
   Go to: `https://github.com/yourusername/fleet-smart-app/settings/secrets/actions`
   
   Add these secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
   - `AWS_REGION`: us-east-1
   - `EC2_HOST`: Your EC2 instance IP
   - `EC2_USER`: ubuntu
   - `EC2_SSH_KEY`: Contents of `~/.ssh/fleet-smart-key`

### Step 3: Deploy Application

1. **Trigger Deployment**:
   ```bash
   git push origin main
   ```

2. **Monitor Deployment**:
   - Go to: `https://github.com/yourusername/fleet-smart-app/actions`
   - Watch the deployment progress

3. **Access Application**:
   - URL: `http://YOUR_INSTANCE_IP:8069`
   - Create database
   - Install "Fleet Smart" app
   - Start managing your EV fleet!

## 🔧 Fleet Smart Application Features

### EV Vehicle Management
- **License Plate Tracking**: Unique identifiers for each vehicle
- **Vehicle Models**: Tesla Model 3, Nissan Leaf, etc.
- **Driver Assignments**: Track who's driving which vehicle
- **Battery Monitoring**: Real-time battery level tracking (%)
- **Location Tracking**: Current vehicle locations
- **Status Management**: Available, In Use, Charging, Maintenance

### Sample Data Included
- **EV-001**: Tesla Model 3, John Doe, 85% battery, Downtown Office
- **EV-002**: Nissan Leaf, Jane Smith, 92% battery, Warehouse

### Web Interface
- **Dashboard View**: Overview of all vehicles
- **List View**: Detailed vehicle information
- **Form View**: Edit vehicle details
- **Search & Filter**: Find vehicles quickly

## 📊 Monitoring & Maintenance

### Health Monitoring
The `health_monitor.sh` script checks:
- ✅ Docker service status
- ✅ Container health (Odoo & PostgreSQL)
- ✅ HTTP response (port 8069)
- ✅ Disk space usage
- ✅ Memory usage
- 🔄 Automatic container restart if needed

### Set Up Monitoring (Optional)
```bash
# SSH to your EC2 instance
ssh -i ~/.ssh/fleet-smart-key ubuntu@YOUR_INSTANCE_IP

# Set up cron job for health monitoring
crontab -e
# Add this line:
*/5 * * * * /home/ubuntu/fleet-smart-app/health_monitor.sh
```

### Telegram Notifications (Optional)
1. **Create Telegram Bot**:
   - Message @BotFather on Telegram
   - Create new bot: `/newbot`
   - Get bot token

2. **Get Chat ID**:
   - Message your bot
   - Visit: `https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates`
   - Find your chat ID

3. **Configure Environment**:
   ```bash
   export TELEGRAM_BOT_TOKEN="your_bot_token"
   export TELEGRAM_CHAT_ID="your_chat_id"
   ```

## 🛠️ Useful Commands

### Local Development
```bash
# Start locally
docker-compose up -d

# View logs
docker-compose logs -f

# Stop containers
docker-compose down

# Reset everything
docker-compose down -v
```

### EC2 Management
```bash
# SSH to server
ssh -i ~/.ssh/fleet-smart-key ubuntu@YOUR_INSTANCE_IP

# View application logs
cd fleet-smart-app && sudo docker-compose logs -f

# Restart application
cd fleet-smart-app && sudo docker-compose restart

# Update application
cd fleet-smart-app && git pull && sudo docker-compose up -d --build

# Check system resources
df -h        # Disk usage
free -h      # Memory usage
htop         # Process monitor
```

### Terraform Management
```bash
# View current infrastructure
terraform show

# Update infrastructure
terraform plan
terraform apply

# Destroy infrastructure (⚠️ This will delete everything!)
terraform destroy
```

## 💰 Cost Estimation

### AWS Resources (Monthly)
- **EC2 t3.medium**: ~$30-35/month
- **Elastic IP**: ~$3.65/month (when not attached to running instance)
- **EBS Storage**: ~$2-5/month (depending on usage)
- **Data Transfer**: ~$1-5/month (depending on traffic)

**Total**: ~$35-50/month

### Cost Optimization Tips
- Use `t3.small` for development ($15-20/month)
- Stop instance when not needed (pay only for storage)
- Use Reserved Instances for production (up to 75% savings)

## 🔒 Security Best Practices

### Implemented Security
- ✅ Security Groups restrict access to necessary ports only
- ✅ SSH key-based authentication (no passwords)
- ✅ Odoo user permissions and access controls
- ✅ Docker container isolation
- ✅ Automated security updates via user-data script

### Additional Recommendations
- 🔐 Enable AWS CloudTrail for audit logging
- 🔐 Set up AWS Config for compliance monitoring
- 🔐 Use AWS Systems Manager for patch management
- 🔐 Enable VPC Flow Logs for network monitoring
- 🔐 Consider using AWS Application Load Balancer with SSL

## 🚨 Troubleshooting

### Common Issues

1. **GitHub Action Fails**:
   ```bash
   # Check secrets are set correctly
   # Verify EC2 instance is running
   # Check security group allows SSH (port 22)
   ```

2. **Can't Access Odoo**:
   ```bash
   # Check security group allows port 8069
   # Verify containers are running: docker-compose ps
   # Check logs: docker-compose logs odoo
   ```

3. **Database Connection Issues**:
   ```bash
   # Restart containers: docker-compose restart
   # Check PostgreSQL logs: docker-compose logs db
   ```

4. **Out of Disk Space**:
   ```bash
   # Clean Docker: docker system prune -a
   # Check disk usage: df -h
   # Clean logs: sudo journalctl --vacuum-time=7d
   ```

### Getting Help
1. Check container logs: `docker-compose logs`
2. Check system logs: `sudo journalctl -u docker`
3. SSH to instance and investigate
4. Review GitHub Actions logs
5. Check AWS CloudWatch logs

## 🎯 Next Steps & Enhancements

### Immediate Improvements
- [ ] Set up SSL certificate with Let's Encrypt
- [ ] Configure domain name with Route 53
- [ ] Set up automated backups
- [ ] Implement log aggregation

### Advanced Features
- [ ] Multi-environment setup (dev/staging/prod)
- [ ] Blue-green deployments
- [ ] Auto-scaling with Application Load Balancer
- [ ] Database clustering for high availability
- [ ] Monitoring with CloudWatch and Grafana

### Fleet Smart App Enhancements
- [ ] Mobile app for drivers
- [ ] GPS integration for real-time tracking
- [ ] Charging station management
- [ ] Maintenance scheduling
- [ ] Cost tracking and reporting
- [ ] Integration with fleet management APIs

## 🎉 Conclusion

You now have a complete, production-ready EV Fleet Management System with:

- ✅ **Automated deployment** to AWS EC2
- ✅ **Scalable architecture** with Docker containers
- ✅ **Infrastructure as Code** with Terraform
- ✅ **Continuous deployment** with GitHub Actions
- ✅ **Health monitoring** with automatic recovery
- ✅ **Professional EV fleet management** capabilities

Your Fleet Smart application is ready to manage electric vehicle fleets with battery monitoring, location tracking, and driver management - all deployed automatically to the cloud!

**Happy fleet managing!** 🚗⚡
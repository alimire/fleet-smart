# Fleet Smart - EV Fleet Management System

A comprehensive Electric Vehicle fleet management system built with Odoo 17, featuring automated deployment to AWS EC2 using GitHub Actions.

## Features

- 🚗 **EV Fleet Management**: Track electric vehicles with battery levels, locations, and status
- 🔋 **Battery Monitoring**: Real-time battery level tracking for all vehicles
- 📍 **Location Tracking**: Monitor vehicle locations and assignments
- 👥 **Driver Management**: Assign and track drivers for each vehicle
- 📊 **Status Management**: Track vehicle availability (Available, In Use, Charging, Maintenance)
- 🐳 **Containerized**: Docker-based deployment for easy scaling
- ☁️ **Cloud Ready**: Automated AWS EC2 deployment with GitHub Actions

## Quick Start (Local Development)

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url>
   cd fleet-smart-app
   ```

2. **Start the application**:
   ```bash
   docker-compose up -d
   ```

3. **Access Odoo**:
   - Open http://localhost:8069
   - Create a database
   - Install the "Fleet Smart" app
   - Start managing your EV fleet!

## AWS Deployment

### Prerequisites

- AWS CLI installed and configured
- Terraform installed
- GitHub repository with this code

### Setup AWS Infrastructure

1. **Run the setup script**:
   ```bash
   ./setup-aws-deployment.sh
   ```

2. **Add GitHub Secrets**:
   Go to your GitHub repository → Settings → Secrets and variables → Actions
   
   Add these secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key  
   - `AWS_REGION`: us-east-1
   - `EC2_HOST`: Your EC2 instance IP (from setup script output)
   - `EC2_USER`: ubuntu
   - `EC2_SSH_KEY`: Your private SSH key (from setup script output)

3. **Deploy**:
   ```bash
   git add .
   git commit -m "Initial Fleet Smart deployment"
   git push origin main
   ```

The GitHub Action will automatically deploy your Fleet Smart app to EC2!

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│ GitHub Actions  │───▶│   AWS EC2       │
│                 │    │                 │    │                 │
│ - Fleet Smart   │    │ - Build         │    │ - Docker        │
│ - Docker Config │    │ - Test          │    │ - Odoo 17       │
│ - Terraform     │    │ - Deploy        │    │ - PostgreSQL    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Project Structure

```
fleet-smart-app/
├── addons/
│   └── fleet_smart/          # Custom Odoo addon
│       ├── models/           # Vehicle models
│       ├── views/            # UI views
│       ├── data/             # Sample data
│       └── security/         # Access controls
├── .github/
│   └── workflows/
│       └── deploy.yml        # GitHub Actions workflow
├── terraform/                # AWS infrastructure
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── scripts/
│   └── deploy.sh            # Deployment script
├── docker-compose.yml       # Container orchestration
├── Dockerfile              # Odoo container
└── README.md
```

## Fleet Smart App Features

### Vehicle Management
- License plate tracking
- Vehicle model information
- Driver assignments
- Battery level monitoring (%)
- Current location tracking
- Status management (Available, In Use, Charging, Maintenance)

### Sample Data
The app comes with sample vehicles:
- **EV-001**: Tesla Model 3 (85% battery, Downtown Office)
- **EV-002**: Nissan Leaf (92% battery, Warehouse)

## Monitoring & Health Checks

The deployment includes:
- Docker health checks for Odoo container
- Automated container restart on failure
- Optional Telegram notifications (configure `notify_telegram.sh`)

## Customization

### Adding New Vehicle Fields
1. Edit `addons/fleet_smart/models/fleet_vehicle.py`
2. Add new fields to the model
3. Update views in `addons/fleet_smart/views/fleet_vehicle_views.xml`
4. Rebuild and deploy

### Telegram Notifications
1. Create a Telegram bot via @BotFather
2. Set environment variables:
   ```bash
   export TELEGRAM_BOT_TOKEN="your_bot_token"
   export TELEGRAM_CHAT_ID="your_chat_id"
   ```
3. Run `./health_monitor.sh` via cron for automated monitoring

## Troubleshooting

### Local Development
- **Container won't start**: Check `docker-compose logs odoo`
- **Database issues**: Run `docker-compose down -v` to reset volumes
- **Port conflicts**: Change port in `docker-compose.yml`

### AWS Deployment
- **GitHub Action fails**: Check repository secrets are set correctly
- **EC2 connection issues**: Verify security group allows port 8069
- **Deployment timeout**: Check EC2 instance logs via SSH

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with `docker-compose up`
5. Submit a pull request

## License

This project is licensed under the LGPL-3 License - see the LICENSE file for details.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review container logs
3. Open a GitHub issue with detailed information

---

**Fleet Smart** - Powering the future of electric vehicle fleet management! ⚡🚗
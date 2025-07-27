#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC}  $1"
}

print_header "Fleet Smart Domain Setup"

echo "This script will help you set up a custom domain for your Fleet Smart app."
echo ""
echo "Options:"
echo "1. Free domain from Freenom (.tk, .ml, .ga, .cf)"
echo "2. Free subdomain (GitHub Pages, Netlify, etc.)"
echo "3. Use existing domain"
echo ""

read -p "Choose an option (1-3): " choice

case $choice in
    1)
        print_header "Free Domain Setup (Freenom)"
        echo "1. Go to: https://www.freenom.com"
        echo "2. Search for your desired domain name"
        echo "3. Choose a free extension: .tk, .ml, .ga, .cf"
        echo "4. Register for 12 months (free)"
        echo "5. In DNS settings, add an A record:"
        echo "   - Name: @ (or leave blank)"
        echo "   - Type: A"
        echo "   - Value: 54.237.91.76"
        echo "   - TTL: 3600"
        echo ""
        print_info "After setup, your Fleet Smart app will be available at your custom domain!"
        ;;
    2)
        print_header "Free Subdomain Setup"
        echo "Popular free subdomain services:"
        echo ""
        echo "🔹 Netlify (fleetsmart.netlify.app):"
        echo "   1. Go to: https://netlify.com"
        echo "   2. Create account and new site"
        echo "   3. Use proxy/redirect to: http://54.237.91.76:8069"
        echo ""
        echo "🔹 GitHub Pages (yourusername.github.io/fleetsmart):"
        echo "   1. Create a new repository: fleetsmart-redirect"
        echo "   2. Add index.html with redirect to your EC2 instance"
        echo "   3. Enable GitHub Pages"
        echo ""
        echo "🔹 Vercel (fleetsmart.vercel.app):"
        echo "   1. Go to: https://vercel.com"
        echo "   2. Create new project"
        echo "   3. Set up redirect to: http://54.237.91.76:8069"
        ;;
    3)
        print_header "Existing Domain Setup"
        echo "If you have an existing domain:"
        echo ""
        echo "1. Access your domain's DNS settings"
        echo "2. Add an A record:"
        echo "   - Name: @ (for root domain) or www"
        echo "   - Type: A"
        echo "   - Value: 54.237.91.76"
        echo "   - TTL: 3600"
        echo ""
        echo "3. Optional: Add CNAME for www:"
        echo "   - Name: www"
        echo "   - Type: CNAME"
        echo "   - Value: yourdomain.com"
        ;;
    *)
        echo "Invalid option selected."
        exit 1
        ;;
esac

print_header "Additional Setup Steps"

echo "After setting up your domain:"
echo ""
echo "1. 🔒 SSL Certificate (Free with Let's Encrypt):"
echo "   - SSH to your server: ssh -i ~/.ssh/fleet-smart-key ubuntu@54.237.91.76"
echo "   - Install certbot: sudo apt install certbot python3-certbot-nginx"
echo "   - Get certificate: sudo certbot --nginx -d yourdomain.com"
echo ""
echo "2. 🌐 Update Odoo Configuration:"
echo "   - Update website domain in Odoo settings"
echo "   - Configure proper base URL"
echo ""
echo "3. 🚀 Deploy Website Module:"
echo "   - The Fleet Smart website module is ready to install"
echo "   - It will create a beautiful public website"
echo ""

print_status "Domain setup guide complete!"
print_info "Your Fleet Smart app will look like a professional website once configured!"

echo ""
echo "🎯 Next steps:"
echo "1. Choose and register your domain"
echo "2. Update DNS settings"
echo "3. Install the Fleet Smart Website module"
echo "4. Configure SSL certificate"
echo ""
echo "Your visitors will see a beautiful website instead of the Odoo backend!"
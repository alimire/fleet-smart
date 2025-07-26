terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Security Group
resource "aws_security_group" "fleet_smart_sg" {
  name_prefix = "fleet-smart-"
  description = "Security group for Fleet Smart application"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Odoo"
    from_port   = 8069
    to_port     = 8069
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fleet-smart-sg"
  }
}

# Key Pair
resource "aws_key_pair" "fleet_smart_key" {
  key_name   = "fleet-smart-key"
  public_key = var.public_key
}

# EC2 Instance
resource "aws_instance" "fleet_smart" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name              = aws_key_pair.fleet_smart_key.key_name
  vpc_security_group_ids = [aws_security_group.fleet_smart_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io docker-compose git curl
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              
              # Install Docker Compose v2
              curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              
              # Clone repository (will be updated by GitHub Actions)
              cd /home/ubuntu
              git clone https://github.com/your-username/fleet-smart-app.git || true
              chown -R ubuntu:ubuntu /home/ubuntu/fleet-smart-app
              EOF

  tags = {
    Name = "fleet-smart-server"
  }
}

# Elastic IP
resource "aws_eip" "fleet_smart_eip" {
  instance = aws_instance.fleet_smart.id
  domain   = "vpc"

  tags = {
    Name = "fleet-smart-eip"
  }
}
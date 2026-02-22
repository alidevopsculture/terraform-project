-> **Terraform EC2 Project: Code Block-by-Block Explanation**
**1. Provider Configuration**
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
**Purpose**: Tells Terraform to download AWS provider (version 6.x) and connect to us-east-1 region using your AWS credentials from aws configure.

**2. Data Source - Dynamic AMI Lookup**
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical (Ubuntu)
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
**Purpose:** Automatically finds latest Ubuntu 22.04 AMI. No hardcoded AMI IDs. Returns data.aws_ami.ubuntu.id for EC2.

**3. Security Group (Virtual Firewall)**
text
resource "aws_security_group" "web" {
  name_prefix = "ali-terraform-"
  
  ingress {
    from_port   = 80    # HTTP for Nginx
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Internet access
  }
  
  ingress {
    from_port   = 22    # SSH access
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0     # All outbound (apt updates)
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
**Purpose:** Opens Port 80 (browser→Nginx) + Port 22 (SSH login). Default denies everything.
**4. EC2 Instance (Main Resource)**
text
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"              # Free tier
  vpc_security_group_ids = [aws_security_group.web.id]
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>✅ Success!</h1>" > /var/www/html/index.html
  EOF
  )
  
  tags = { Name = "Mini-project-Ali" }
}
**Purpose:** Launches Ubuntu VM with auto Nginx setup. Zero manual SSH required.

**5. Output**
text
output "instance_ip" {
  value = aws_instance.web.public_ip
}
**Purpose:** Prints public IP after terraform apply for browser testing.

**Execution Flow**
text
terraform init    → Downloads AWS provider
terraform plan    → Shows "Will create 2 resources"
terraform apply   → Deploys EC2 + Security Group (3 mins)
terraform output  → Gives IP: 54.123.45.67
curl 54.123.45.67 → Shows your webpage!
terraform destroy → Cleanup (important!)

**What Makes This Production-Ready**
Dynamic AMI - Always latest Ubuntu
user_data - Zero-touch automation
Security Groups - Proper firewall rules
Clean Git - .gitignore excludes binaries
Free Tier - Zero AWS cost

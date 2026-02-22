# 🚀 Terraform EC2 Auto-Deploy Project

> **Zero-touch EC2 deployment with Nginx** — From code to live server in 3 minutes

[![Terraform](https://img.shields.io/badge/Terraform-~%3E6.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-EC2-FF9900?logo=amazon-aws)](https://aws.amazon.com/ec2/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420?logo=ubuntu)](https://ubuntu.com/)

---

## 📋 What This Does

Automatically provisions an AWS EC2 instance running **Nginx web server** with:
- ✅ Dynamic Ubuntu 22.04 AMI lookup
- ✅ Automated Nginx installation (no SSH needed)
- ✅ Production-ready security groups
- ✅ Free tier eligible (t3.micro)

---

## 🏗️ Architecture

```
Internet → Security Group (Port 80/22) → EC2 Instance → Nginx Server
                                          ↓
                                    Ubuntu 22.04 (Auto-selected)
```

---

## 🔧 Code Breakdown

### 1️⃣ **Provider Configuration**
```hcl
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
```
**Purpose:** Configures Terraform to use AWS provider v6.x in `us-east-1` region.

---

### 2️⃣ **Dynamic AMI Lookup**
```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
```
**Purpose:** Automatically fetches the latest Ubuntu 22.04 AMI. No hardcoded IDs!

---

### 3️⃣ **Security Group (Firewall)**
```hcl
resource "aws_security_group" "web" {
  name_prefix = "ali-terraform-"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTP access
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # All outbound
  }
}
```
**Purpose:** Opens **Port 80** (web traffic) and **Port 22** (SSH). Allows outbound for updates.

---

### 4️⃣ **EC2 Instance with Auto-Setup**
```hcl
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
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

  tags = {
    Name = "Mini-project-Ali"
  }
}
```
**Purpose:** Launches EC2 with automated Nginx installation via `user_data` script.

---

### 5️⃣ **Output Public IP**
```hcl
output "instance_ip" {
  value = aws_instance.web.public_ip
}
```
**Purpose:** Displays the server's public IP after deployment.

---

## 🚦 Quick Start

### Prerequisites
- [Terraform](https://www.terraform.io/downloads) installed
- AWS CLI configured (`aws configure`)
- AWS account with EC2 permissions

### Deploy in 4 Commands
```bash
# 1. Initialize Terraform
terraform init

# 2. Preview changes
terraform plan

# 3. Deploy infrastructure
terraform apply -auto-approve

# 4. Get your server IP
terraform output instance_ip
```

### Test Your Server
```bash
# Copy the IP from output and visit in browser
http://<your-instance-ip>

# Or use curl
curl http://$(terraform output -raw instance_ip)
```

You should see: **✅ Success!**

---

## 🧹 Cleanup

**Important:** Destroy resources to avoid charges
```bash
terraform destroy -auto-approve
```

---

## 🌟 Production-Ready Features

| Feature | Benefit |
|---------|---------|
| **Dynamic AMI** | Always uses latest Ubuntu (no manual updates) |
| **user_data** | Zero-touch automation (no SSH required) |
| **Security Groups** | Proper firewall rules (HTTP + SSH only) |
| **Free Tier** | t3.micro instance (eligible for AWS free tier) |
| **Clean Git** | `.gitignore` excludes Terraform state files |

---

## 📁 Project Structure

```
terraform-ec2-provision/
├── main.tf           # All infrastructure code
├── .gitignore        # Excludes .terraform/, *.tfstate
└── README.md         # This file
```

---

## 🔒 Security Notes

⚠️ **Production Recommendations:**
- Replace `0.0.0.0/0` with your IP: `["YOUR_IP/32"]`
- Use SSH key pairs for authentication
- Enable AWS CloudWatch monitoring
- Store state in S3 with encryption

---

## 📚 Learn More

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EC2 User Data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

---

## 👤 Author

**Ali** - Terraform Learning Project
> 🔗 LinkedIn: [www.linkedin.com/in/alimurtazadevops](https://www.linkedin.com/in/alimurtazadevops)


---

## 📝 License

This project is open source and available for educational purposes.

---

**⭐ Star this repo if you found it helpful!**

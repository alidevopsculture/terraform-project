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

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
}

resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  # Security group inline
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo "<h1>✅ Ali's Ubuntu Terraform SUCCESS! $(hostname -f)</h1><p>$(date)</p>" > echo "<h1>✅ Ali's Ubuntu Terraform SUCCESS! $(hostname -f)</h1><p>$(date)</p>"
  EOF
    )
     
  tags = {
    Name = "Mini-project-Ali"
  }
}

resource "aws_security_group" "web" {
    name_prefix = "ali-terraform-sg-"
    ingress { # inbound rule
        description = "HTTP from anywhere"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH from anywhere"
        from_port   = 22
        to_port     = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress { # outbound rule
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "instance_ip" {
    value = aws_instance.web.public_ip
}
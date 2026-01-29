terraform {
  backend "s3" {
    bucket  = "techbleat-cicd-state-bucket-week-7"
    key     = "envs/dev/terraform.tfstate"
    region  = "eu-north-1"
    encrypt = true

  }
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# -------------------------
# Web Node Security Group
# -------------------------

# NGINX backend setup

resource "aws_security_group" "nginx_sg" {

  name        = "nginx-sg"
  description = "Allow SSH and Port 8000  inbound, all outbound"
  vpc_id      = var.project_vpc


  # inbound SSH

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # inbound 80 (nginx)
  ingress {
    description = "Web port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-app-security_group"
  }

}

resource "aws_instance" "nginx-node" {
  ami                    = var.project_ami
  instance_type          = var.project_instance_type
  subnet_id              = var.project_subnet
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  key_name               = var.project_keyname

  tags = {
    Name = "nginx-node"
  }
  
}

# Java backend setup

resource "aws_security_group" "java_sg" {

  name        = "java-sg"
  description = "Allow SSH and Port 9090  inbound, all outbound"
  vpc_id      = var.project_vpc


  # inbound SSH

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   # inbound 80 (web)
  ingress {
    description = "Web port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "java-app-security_group"
  }

}

# Java backend setup

#-------------------------
# Java EC2 Instance
# ------------------------


resource "aws_instance" "java-node" {
  ami                    = var.project_ami
  instance_type          = var.project_instance_type
  subnet_id              = var.project_subnet
  vpc_security_group_ids = [aws_security_group.java_sg.id]
  key_name               = var.project_keyname

  tags = {
    Name = "java-node"
  }
}


#--------------------------------
# Outputs - Public (external) IPs
#--------------------------------

output "nginx_node_ip" {
  description = " Public IP"
  value  = aws_instance.nginx-node.public_ip
}

output "java_node_ip" {
  description = " Public IP"
  value  = aws_instance.java-node.public_ip
}
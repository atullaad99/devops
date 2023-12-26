variable "create_s3" {
  description = "Flag to conditionally create S3 bucket or EC2 instance"
  type        = bool
  default     = true
}

provider "aws" {
  region      = "ap-south-1"
  access_key  = "AKIAS6KNDF7P342ODSU5"
  secret_key  = "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"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "terraformb808"
    key    = "myapp/dev/terraform.tfstate"
    region = "ap-south-1"
  }
}

resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

variable "key_name" {}

resource "aws_key_pair" "terraform_key" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.rsa_4096.private_key_pem
  filename = var.key_name
}

resource "aws_instance" "aws_instance" {
  count = var.create_s3 ? 0 : 1  # 0 instances if create_s3 is true, 1 instance otherwise

  ami           = "ami-0a0f1259dd1c90938"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.terraform_key.key_name

  tags = {
    Name = "aws_instance"
  }
}


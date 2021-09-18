terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_instance" "web1" {
  ami           = "${data.aws_ami.latest-amzn2.id}"
  instance_type = "t2.micro"
  security_groups = [ "allow_www_sg1", "allow_ssh_sg1", "default" ]
  key_name      = var.keyname

  tags = {
    Name = var.instance_name
  }
}

resource "aws_instance" "web2" {
  ami           = "${data.aws_ami.latest-amzn2.id}"
  instance_type = "t2.micro"
  security_groups = [ "allow_www_sg1", "allow_ssh_sg1", "default" ]
  key_name      = var.keyname

  tags = {
    Name = var.instance_name
  }
}

resource "aws_security_group" "allow_www_sg1" {
  name = "allow_www_sg1"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_ssh_sg1" {
  name = "allow_ssh_sg1"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ var.selfa, var.selfb ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "latest-amzn2" {
  most_recent = true
  owners = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

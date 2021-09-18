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
  region  = "us-east-1"
}

resource "aws_security_group" "allow_www_sg1" {
  name        = "allow_www_sg1"
  description = "Allow inbound web traffic"

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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags  = {
    Name = "allow_www_sg1"
  }
}

resource "aws_security_group" "allow_ssh_sg1" {
  name        = "allow_ssh_sg1"
  description = "Allow inbound ssh traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ var.selfa, var.selfb ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_sg1"
  }
}

resource "aws_network_interface" "eni1" {
  subnet_id = "subnet-d64e26b2"
  security_groups = [
    "${aws_security_group.allow_www_sg1.id}",
    "${aws_security_group.allow_ssh_sg1.id}"
  ]
}

resource "aws_network_interface" "eni2" {
  subnet_id = "subnet-4490356b"
  security_groups = [
    "${aws_security_group.allow_www_sg1.id}",
    "${aws_security_group.allow_ssh_sg1.id}"
  ]
}

resource "aws_instance" "web1" {
  ami           = "${data.aws_ami.latest-amzn2.id}"
  instance_type = "t2.micro"
  key_name      = var.keyname

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.eni1.id}"
  }

  tags = {
    Name = var.instance_name
  }
}

resource "aws_instance" "web2" {
  ami           = "${data.aws_ami.latest-amzn2.id}"
  instance_type = "t2.micro"
  key_name      = var.keyname

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.eni2.id}"
  }

  tags = {
    Name = var.instance_name
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "alb1"

  load_balancer_type = "application"

  vpc_id             = "vpc-fe066986"
  subnets            = ["subnet-d64e26b2", "subnet-4490356b"]
  security_groups    = [ "${aws_security_group.allow_www_sg1.id}" ]

  #access_logs = {
  #  bucket = var.lblogs
  #}

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = [
        {
          target_id = "${aws_instance.web1.id}"
          port = 80
        },
        {
          target_id = "${aws_instance.web2.id}"
          port = 80
        }
      ]
    }
  ]

  #https_listeners = [
  #  {
  #    port               = 443
  #    protocol           = "HTTPS"
  #    certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
  #    target_group_index = 0
  #  }
  #]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
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

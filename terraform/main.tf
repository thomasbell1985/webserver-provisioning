terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">=0.14.9"
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

# ami-04505e74c0741db8d
data "aws_availability_zones" "available" {}

module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "3.2.0"
  name            = var.vpc_name
  cidr            = var.vpc_cidr
  azs             = data.aws_availability_zones.available.names
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = var.public_ssh_key
}



resource "aws_security_group" "webserver_security_group" {
  name   = "web_server_security_group"
  vpc_id = module.vpc.vpc_id
  ingress = [{
    # allow all inbound http traffic
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "allows all inbound http on port 80"
    from_port        = 1
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "tcp"
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    to_port          = 80
    },
    {
      # allow all inbound http traffic
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "allows all inbound ssh traffic"
      from_port        = 1
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      protocol         = "tcp"
      self             = false
      to_port          = 22
    }
  ]
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_instance" "web_server" {
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  depends_on = [
    module.vpc.public_subnets
  ]
  for_each               = toset(module.vpc.public_subnets)
  subnet_id              = each.key
  vpc_security_group_ids = [aws_security_group.webserver_security_group.id]
  tags = {
    Name = "webserver-subnet-${each.value}"
  }
  key_name = aws_key_pair.ssh_key.key_name
}

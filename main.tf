terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0.0"
}

# provider "aws" {
#   region = "us-east-1"
# }

provider "aws" {
  region     = "us-east-1"
  access_key = "null"
  secret_key = "null"
  # s3_use_path_style           = false
  # skip_credentials_validation = true
  # skip_metadata_api_check     = true
  # skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:4566"
    apigatewayv2   = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    es             = "http://localhost:4566"
    elasticache    = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    rds            = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    route53        = "http://localhost:4566"
    s3             = "http://s3.localhost.localstack.cloud:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

module "vpc" {
  source               = "./modules/networking"
  prefix               = var.prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

module "web_server_sg" {
  source      = "./modules/security"
  prefix      = "openwebui-server"
  description = "Security group for web servers"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = var.ingress_rules

  egress_rules = var.egress_rules

  tags = var.tags

}

module "instance_ollama" {
  source            = "./modules/compute"
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = module.vpc.public_subnets_ids[0]
  security_group_id = module.web_server_sg.security_group_id

  user_data = <<-EOF
              #!/bin/bash
              #Install Docker
              sudo yum update -y
              sudo amazon-linux-extras install docker -y
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker $USER
              newgrp docker

              #Install git
              sudo yum install git -y
              EOF

  server_name = {
    Name = "ollama-server"
  }
}

module "instance_openwebui" {
  source            = "./modules/compute"
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = module.vpc.public_subnets_ids[1]
  security_group_id = module.web_server_sg.security_group_id

  user_data = <<-EOF
              #!/bin/bash
              #Install Docker
              sudo yum update -y
              sudo amazon-linux-extras install docker -y
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker $USER
              newgrp docker

              #Install git
              sudo yum install git -y
              EOF

  server_name = {
    Name = "openwebui-server"
  }
}

module "load_balancer" {
  source = "./modules/load_balancer"

  # Valores que necesitas especificar
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.public_subnets_ids
  security_group_id   = module.web_server_sg.security_group_id
  target_instance_ids = [module.instance_ollama.instance_id, module.instance_openwebui.instance_id]

  # Opciones del balanceador de carga y grupo de destino
  # lb_name               = var.lb_name
  # target_group_name     = var.target_group_name
  # listener_port         = var.listener_port
  # listener_protocol     = var.listener_protocol
  # target_group_port     = var.target_group_port
  # target_group_protocol = var.target_group_protocol
  # target_type           = var.target_type
}

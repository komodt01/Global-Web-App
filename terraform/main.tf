terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ------------------------------------------------------------
# PROVIDERS
# ------------------------------------------------------------

provider "aws" {
  alias  = "primary"
  region = var.aws_region_primary
}

provider "aws" {
  alias  = "secondary"
  region = var.aws_region_secondary
}

# ------------------------------------------------------------
# IAM / SYSTEMS MANAGER
# ------------------------------------------------------------

# Shared EC2 role used by instances in both regions for
# AWS Systems Manager administration.
resource "aws_iam_role" "ec2_ssm_role" {
  name = "global-web-app-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Project = "Global-Web-App"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "global-web-app-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# ------------------------------------------------------------
# PRIMARY REGION NETWORK
# ------------------------------------------------------------

resource "aws_vpc" "primary" {
  provider = aws.primary

  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "global-web-app-primary-vpc"
    Project = "Global-Web-App"
    Region  = var.aws_region_primary
  }
}

resource "aws_internet_gateway" "primary" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary.id

  tags = {
    Name = "global-web-app-primary-igw"
  }
}

resource "aws_subnet" "primary_public" {
  provider = aws.primary

  vpc_id                  = aws_vpc.primary.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "global-web-app-primary-public"
  }
}

resource "aws_route_table" "primary_public" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary.id
  }

  tags = {
    Name = "global-web-app-primary-public"
  }
}

resource "aws_route_table_association" "primary_public" {
  provider = aws.primary

  subnet_id      = aws_subnet.primary_public.id
  route_table_id = aws_route_table.primary_public.id
}

resource "aws_security_group" "primary_web" {
  provider = aws.primary

  name        = "global-web-app-primary-web"
  description = "Web access for primary-region NGINX instance"
  vpc_id      = aws_vpc.primary.id

  ingress {
    description = "HTTP web traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "global-web-app-primary-web"
  }
}

# ------------------------------------------------------------
# SECONDARY REGION NETWORK
# ------------------------------------------------------------

resource "aws_vpc" "secondary" {
  provider = aws.secondary

  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "global-web-app-secondary-vpc"
    Project = "Global-Web-App"
    Region  = var.aws_region_secondary
  }
}

resource "aws_internet_gateway" "secondary" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary.id

  tags = {
    Name = "global-web-app-secondary-igw"
  }
}

resource "aws_subnet" "secondary_public" {
  provider = aws.secondary

  vpc_id                  = aws_vpc.secondary.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "global-web-app-secondary-public"
  }
}

resource "aws_route_table" "secondary_public" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary.id
  }

  tags = {
    Name = "global-web-app-secondary-public"
  }
}

resource "aws_route_table_association" "secondary_public" {
  provider = aws.secondary

  subnet_id      = aws_subnet.secondary_public.id
  route_table_id = aws_route_table.secondary_public.id
}

resource "aws_security_group" "secondary_web" {
  provider = aws.secondary

  name        = "global-web-app-secondary-web"
  description = "Web access for secondary-region NGINX instance"
  vpc_id      = aws_vpc.secondary.id

  ingress {
    description = "HTTP web traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "global-web-app-secondary-web"
  }
}

# ------------------------------------------------------------
# AMI LOOKUPS
# ------------------------------------------------------------

data "aws_ami" "primary_amazon_linux" {
  provider    = aws.primary
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "secondary_amazon_linux" {
  provider    = aws.secondary
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------------------------
# WEB SERVERS
# ------------------------------------------------------------

resource "aws_instance" "primary_web" {
  provider = aws.primary

  ami                    = data.aws_ami.primary_amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.primary_public.id
  vpc_security_group_ids = [aws_security_group.primary_web.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>Global Web App - ${var.aws_region_primary}</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name    = "global-web-app-primary"
    Project = "Global-Web-App"
  }
}

resource "aws_instance" "secondary_web" {
  provider = aws.secondary

  ami                    = data.aws_ami.secondary_amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.secondary_public.id
  vpc_security_group_ids = [aws_security_group.secondary_web.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>Global Web App - ${var.aws_region_secondary}</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name    = "global-web-app-secondary"
    Project = "Global-Web-App"
  }
}

# ------------------------------------------------------------
# OUTPUTS
# ------------------------------------------------------------

output "primary_public_ip" {
  description = "Public IP address of the primary-region web server"
  value       = aws_instance.primary_web.public_ip
}

output "secondary_public_ip" {
  description = "Public IP address of the secondary-region web server"
  value       = aws_instance.secondary_web.public_ip
}

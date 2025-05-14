
provider "aws" {
  alias  = "primary"
  region = "us-east-1"
}

provider "aws" {
  alias  = "secondary"
  region = "ap-southeast-1"
}

# PRIMARY REGION NETWORKING
resource "aws_vpc" "primary_vpc" {
  provider   = aws.primary
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = { Name = "primary-vpc" }
}

resource "aws_subnet" "web_subnet" {
  provider          = aws.primary
  vpc_id            = aws_vpc.primary_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "primary-subnet" }
}

resource "aws_security_group" "web_sg" {
  provider = aws.primary
  name        = "primary-web-sg"
  description = "Allow HTTP, HTTPS, and SSH"
  vpc_id      = aws_vpc.primary_vpc.id

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

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS only"
  }

  tags = { Name = "web-sg" }
}

# PRIMARY INSTANCE
resource "aws_instance" "web_server" {
  provider = aws.primary
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.small"
  subnet_id     = aws_subnet.web_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install nginx1 -y
              systemctl enable nginx
              systemctl start nginx
              yum install -y https://s3.amazonaws.com/amazon-ssm-us-east-1/latest/linux_amd64/amazon-ssm-agent.rpm
              systemctl enable amazon-ssm-agent
              systemctl start amazon-ssm-agent
              echo "<h1>Global Web App - us-east-1</h1>" > /usr/share/nginx/html/index.html
              EOF

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  tags = { Name = "global-webapp-nginx-us-east-1" }
}

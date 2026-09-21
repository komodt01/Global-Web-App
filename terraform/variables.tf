variable "aws_region_primary" {
  description = "AWS region for the primary web application deployment"
  type        = string
  default     = "us-east-1"
}

variable "aws_region_secondary" {
  description = "AWS region for the secondary web application deployment"
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 instance type used for the regional NGINX web servers"
  type        = string
  default     = "t3.small"
}

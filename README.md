# Global Web App Terraform Deployment

Purpose
This project deploys a simple globally distributed web application across two AWS regions using Terraform.
It is designed as an architecture and operations lab, not a production workload.

What This Project Deploys

Two VPCs (one in us-east-1, one in ap-southeast-1)

Public subnets and Internet Gateways in each region

EC2 instances running NGINX as a basic web server

Security Groups that allow HTTPS and restricted SSH

Optional SSM access for secure remote administration (if enabled in the Terraform variables)

Architecture Overview
Area 1: us-east-1

VPC with a public subnet

NGINX EC2 instance

Internet-facing access over HTTPS

Area 2: ap-southeast-1

VPC with a public subnet

NGINX EC2 instance

Internet-facing access over HTTPS

The two regions are independent in this version.
Global behavior is achieved by deploying the same web tier in multiple regions, not by using a global load balancer.

Prerequisites

AWS account with permissions to create VPCs, EC2, Security Groups, IAM roles, and SSM (if used)

Terraform installed

AWS CLI configured with valid credentials or profile

Optional: key pair or SSM access to log in to the EC2 instances

Deployment Steps

Navigate into the project folder.

Review and update terraform.tfvars or variable values as needed.

Run:
terraform init
terraform plan
terraform apply

Outputs
After apply completes, Terraform returns:

area1_public_ip (EC2 public IP in us-east-1)

area2_public_ip (EC2 public IP in ap-southeast-1)

You can use these IPs in a browser to confirm that NGINX is serving the web page from each region.

Teardown
To destroy all resources created by this deployment, run:
terraform destroy

For full cleanup guidance and notes, see teardown.md.

Documentation
Additional project documentation is included:

project_summary.md

design_overview.md

security_requirements.md

risks_and_mitigations.md

cost_estimate_disclaimer.md

costmodeling.md

compliance_mapping.md

technologies.md

lessonslearned.md

This project is intended for learning, portfolio, and architecture discussion purposes only and is not a production-ready design.

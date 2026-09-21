
# Technologies Used

## Terraform

Used to define and provision the multi-region AWS infrastructure from a single Infrastructure as Code configuration.

## Amazon VPC

Separate VPCs provide independent network boundaries for the primary and secondary AWS regions.

## Amazon EC2

Amazon Linux 2023 EC2 instances host the regional NGINX web servers.

## NGINX

Installed automatically through EC2 user data and used to provide a simple web endpoint in each region.

## AWS Identity and Access Management (IAM)

An EC2 IAM role and instance profile provide the permissions required for AWS Systems Manager.

## AWS Systems Manager

Provides the administrative-access foundation for the EC2 instances without requiring inbound SSH access.

## Internet Gateway and VPC Routing

Each regional VPC includes an Internet Gateway and public route table so the web server can provide an internet-accessible HTTP endpoint.

## EC2 Security Groups

Regional security groups permit inbound HTTP traffic while leaving SSH closed.

## Amazon Linux 2023

The EC2 instances use dynamically discovered Amazon Linux 2023 AMIs appropriate to each AWS region.

---

## Production Services Considered but Not Implemented

A production global web architecture could additionally use:

- Amazon Route 53 for DNS and health-aware routing
- Amazon CloudFront for edge caching and content delivery
- AWS Global Accelerator for global traffic optimization
- AWS WAF for application-layer filtering
- Elastic Load Balancing for regional traffic distribution
- AWS Certificate Manager for TLS certificates
- Amazon CloudWatch for expanded monitoring and alerting

These services represent potential architecture extensions and are not part of the current Terraform implementation.

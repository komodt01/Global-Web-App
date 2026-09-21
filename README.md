# AWS Multi-Region Web Application Architecture

## Project Purpose

This project demonstrates how a simple web workload can be deployed consistently across multiple AWS regions using Terraform.

The architecture deploys independent NGINX web servers in:

- `us-east-1` — primary region
- `ap-southeast-1` — secondary region

Each region receives its own VPC, public subnet, Internet Gateway, route table, security group, and EC2 web server.

The project focuses on **multi-region infrastructure design, repeatable deployment, network isolation, and administrative access** rather than implementing a production global traffic-management platform.

---

## Architecture

The Terraform configuration creates two independent regional environments.

### Primary Region — us-east-1

- VPC: `10.0.0.0/16`
- Public subnet: `10.0.1.0/24`
- Internet Gateway
- Public route table
- EC2 security group
- Amazon Linux 2023 EC2 instance
- NGINX web server

### Secondary Region — ap-southeast-1

- VPC: `10.1.0.0/16`
- Public subnet: `10.1.1.0/24`
- Internet Gateway
- Public route table
- EC2 security group
- Amazon Linux 2023 EC2 instance
- NGINX web server

Terraform uses separate AWS provider aliases to manage resources in both regions from one configuration.

---

## Request Flow

The current lab exposes each regional web server independently.

```text
User
  |
  +----> Public IP — us-east-1 EC2 — NGINX
  |
  +----> Public IP — ap-southeast-1 EC2 — NGINX
```

The two environments do not automatically route traffic between regions.

A production implementation could introduce services such as Route 53, CloudFront, Global Accelerator, load balancers, health checks, and automated failover depending on business and availability requirements.

Those services are intentionally outside the implemented scope of this lab.

---

## Security and Administrative Controls

### Network Separation

Each region uses its own VPC and CIDR range. This provides clear regional network boundaries and avoids overlapping address space between the two environments.

### Security Groups

The web security groups permit inbound HTTP traffic on TCP port 80.

The lab does not expose SSH for administration.

### AWS Systems Manager

Both EC2 instances use an IAM instance profile with the AWS-managed `AmazonSSMManagedInstanceCore` policy.

This establishes the identity foundation for Systems Manager-based administration rather than requiring inbound SSH access.

### Dynamic AMI Selection

Terraform queries AWS for the current Amazon Linux 2023 AMI independently in each region rather than relying on a single hard-coded AMI ID.

This avoids assuming that an AMI identifier is valid across regions.

---

## Infrastructure as Code

All deployable infrastructure is maintained under:

```text
terraform/
├── main.tf
└── variables.tf
```

`main.tf` contains the AWS providers, IAM resources, networking, EC2 instances, bootstrap configuration, and outputs.

`variables.tf` defines the primary region, secondary region, and EC2 instance type.

Keeping the Terraform configuration together prevents separate directories from unintentionally representing different infrastructure states.

---

## Deployment

From the repository root:

```bash
cd terraform
terraform init
terraform validate
terraform plan
terraform apply
```

Terraform provisions both regional environments from the same configuration.

After deployment, the outputs provide the public IP address of each web server:

```text
primary_public_ip
secondary_public_ip
```

Opening either address over HTTP should return a simple NGINX page identifying the AWS region serving the request.

---

## Teardown

From the `terraform` directory:

```bash
terraform destroy
```

Review the Terraform plan before confirming destruction.

See `teardown.md` for additional cleanup guidance.

---

## Architecture Decisions

### Why Two Independent VPCs?

The purpose of the lab is to demonstrate regional infrastructure independence. Each region can be provisioned and operated without depending on the network resources of the other region.

### Why Systems Manager Instead of SSH?

Removing inbound SSH reduces unnecessary administrative exposure. Systems Manager provides an AWS-managed approach for administering EC2 instances using IAM-based access.

### Why No Global Routing Layer?

Deploying infrastructure in multiple regions and globally routing users are separate architectural concerns.

This project intentionally demonstrates the **regional infrastructure layer**. DNS routing, CDN services, health-based failover, TLS termination, WAF protection, and global traffic management would be additional architecture decisions rather than implied capabilities of the current implementation.

---

## Current Scope

Implemented:

- Multi-region AWS provider configuration
- Two independent VPCs
- Two public subnets
- Internet Gateways and public routing
- Regional security groups
- Two Amazon Linux 2023 EC2 instances
- NGINX bootstrap using EC2 user data
- IAM role and instance profile for Systems Manager
- Dynamic regional AMI discovery
- Terraform outputs for both regional web servers

Not implemented:

- Route 53 latency or failover routing
- CloudFront
- AWS Global Accelerator
- Application or Network Load Balancers
- AWS WAF
- TLS certificates or HTTPS termination
- Automated regional failover
- Multi-AZ web tiers
- Auto Scaling
- Centralized application logging or alerting

These distinctions are intentional so the repository accurately represents the infrastructure implemented by the Terraform.

---

## What This Project Demonstrates

This project demonstrates the architectural difference between **deploying a workload in multiple AWS regions** and building a fully managed **global application delivery architecture**.

The Terraform establishes repeatable regional infrastructure and administrative controls while leaving global traffic management, resilience automation, and edge security as explicit future architecture decisions.

That separation is important in enterprise architecture: multi-region deployment creates the infrastructure footprint, but additional controls are required before that footprint becomes a production-grade global service.

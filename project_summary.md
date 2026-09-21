# Project Summary

## Business Problem

A workload deployed in a single AWS region creates geographic concentration and provides no regional deployment alternative if the architecture later needs to support users or operations across multiple locations.

## Architecture Approach

This project establishes a repeatable two-region AWS web infrastructure using Terraform.

Independent environments are deployed in:

- `us-east-1`
- `ap-southeast-1`

Each region contains its own VPC, public subnet, Internet Gateway, routing, security group, and NGINX EC2 web server.

AWS Systems Manager IAM permissions provide the administrative-access foundation without exposing inbound SSH.

## Architecture Objective

The project demonstrates how the same infrastructure pattern can be deployed consistently across AWS regions while maintaining independent regional network boundaries.

It intentionally separates **multi-region infrastructure deployment** from **global traffic management**.

Services such as Route 53, CloudFront, AWS Global Accelerator, WAF, load balancing, health-based routing, and automated failover would be additional production architecture decisions and are not implemented in this lab.

## Key Takeaway

Deploying infrastructure in multiple regions does not by itself create a globally resilient application.

A multi-region footprint establishes the regional foundation. Production resilience requires additional decisions around traffic routing, health detection, failover, data architecture, security controls, observability, and recovery objectives.

# Lessons Learned

## Multi-Region Deployment Is Not Global Traffic Management

Deploying the same workload in multiple AWS regions creates a multi-region infrastructure footprint, but it does not automatically provide global routing, regional failover, or high availability.

Those capabilities require additional services and design decisions such as DNS routing, health checks, load balancing, CDN or edge services, and automated failover.

This distinction became one of the most important architectural lessons from the project.

## Regional Infrastructure Must Be Independently Complete

Each AWS region requires the networking components necessary to support the workload.

For this project, that includes:

- VPC
- Public subnet
- Internet Gateway
- Route table and default route
- Security group
- EC2 instance

Creating an EC2 instance and subnet alone does not make the workload internet accessible.

## Provider Aliases Simplify Multi-Region Terraform

Terraform provider aliases allow resources in multiple AWS regions to be managed from the same configuration.

This makes the regional relationship visible while avoiding separate Terraform projects for infrastructure that follows the same architecture pattern.

## Avoid Hard-Coded Regional AMI IDs

AMI identifiers are regional.

Using Terraform data sources to discover the appropriate Amazon Linux 2023 AMI in each region makes the configuration more portable and reduces dependence on manually maintained AMI IDs.

## Administrative Access Does Not Require SSH

The original design considered SSH access, but the final architecture leaves inbound SSH closed.

Using an EC2 IAM role and Systems Manager permissions provides a stronger administrative-access pattern without exposing TCP port 22 to the internet.

## Infrastructure Documentation Must Match the Code

Architecture documentation should describe what is actually implemented.

Services such as CloudFront, Route 53, WAF, TLS termination, CloudWatch monitoring, and automatic failover may be reasonable production extensions, but they should not be presented as implemented controls when they are not part of the Terraform.

Keeping documentation aligned with Infrastructure as Code makes the repository more useful for architecture reviews and prevents design intent from being confused with deployed capability.

## Future Improvements

A production evolution of this architecture could evaluate:

- Route 53 health-aware or latency-based routing
- CloudFront or AWS Global Accelerator
- Regional load balancers and Auto Scaling
- TLS using AWS Certificate Manager
- AWS WAF
- Centralized logging, metrics, and alerting
- Multi-AZ deployment within each region
- Automated regional failover
- Data replication and recovery requirements

Each addition should be driven by availability, security, performance, recovery, and cost requirements rather than added simply because the service is available.

## Key Takeaway

The strongest lesson from this project is that architecture should clearly separate **what is deployed today** from **what would be required for a production target state**.

Terraform provides the repeatable regional foundation. Global resilience requires additional architectural layers.

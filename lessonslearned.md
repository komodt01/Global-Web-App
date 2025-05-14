# Lessons Learned: Global Web App with Multi-Region EC2 Deployment

## What Went Well
- Successfully used Terraform to provision a global infrastructure footprint.
- Used separate providers and aliases to manage multiple AWS regions clearly.
- Applied subnet naming consistency across regions (Area 1 and Area 2).
- IAM instance profile for SSM access was a great addition to eliminate SSH dependency.
- Used modular security group design, separating each region’s EC2 ingress/egress.
- Integrated user_data for EC2 bootstrapping (NGINX setup) without needing manual login.

## Challenges Encountered
- CIDR block overlaps required careful planning during subnet setup.
- Availability Zone selection needed manual cross-checking to ensure isolation.
- Terraform didn’t support dynamic AZ retrieval without a data source or variable logic.
- Terraform AWS provider must match region-specific resource placement strictly.

## Improvements for Future
- Add modules to encapsulate repeated logic (e.g., VPC, EC2, SG).
- Use `terraform remote state` to split regions into reusable workspaces.
- Add variableized IP whitelisting for SSH (`YOUR_IP/32` should be parameterized).
- Include CloudWatch alarms or logging for deeper observability.
- Consider load balancer integration to enable failover between regions.

## Key Takeaway
Manual subnet/VPC creation in the AWS Console is helpful for validation but ideally avoided in infrastructure-as-code projects. From now on, full automation (including subnet CIDRs and tags) should be implemented in Terraform for portability and version control.

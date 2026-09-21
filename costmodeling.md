# Cost Considerations

## Current Architecture

The primary cost drivers for the implemented lab are the two EC2 instances running in separate AWS regions.

Additional usage-based costs may include:

- EC2 compute
- EBS storage attached to each EC2 instance
- Public IPv4 addressing
- Internet data transfer
- Cross-region traffic if communication between regions is added in the future

The current architecture does not include NAT Gateways, load balancers, CloudFront, Route 53 routing, WAF, or other global traffic-management services.

## Cost Optimization Considerations

For a short-lived architecture lab:

- Destroy resources when testing is complete.
- Use appropriately sized EC2 instances.
- Avoid leaving unused public resources running.
- Review regional pricing differences before long-running deployments.

For a production workload, cost decisions should be evaluated together with availability, performance, security, and recovery requirements.

Reducing infrastructure cost should not remove controls or resilience capabilities required by the business.

## Future Architecture Cost Drivers

If the architecture were expanded into a production global service, additional cost areas could include:

- Global DNS and health checks
- CDN or global traffic acceleration
- Regional load balancers
- AWS WAF
- Centralized logging and monitoring
- Multi-AZ compute
- Auto Scaling
- Data replication
- Backup and disaster recovery

These services are not included in the current Terraform implementation.

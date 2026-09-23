# Trust Boundaries in the Multi-Region Web Architecture

## Regional Isolation Does Not Mean Complete Security Isolation

This project deploys the same basic web workload into two AWS regions:

* `us-east-1`
* `ap-southeast-1`

Each region has its own VPC, subnet, Internet Gateway, route table, security group, and EC2 instance.

That creates meaningful regional and network separation.

It does not create two completely independent security environments.

Some controls are regional, while others operate at the AWS account level and are shared by resources in both regions. Understanding that distinction is important when evaluating the security and resilience of a multi-region architecture.

## What Is Regionally Independent

The primary and secondary environments use separate VPCs and non-overlapping address ranges.

```text
us-east-1
10.0.0.0/16
    |
    +-- Public Subnet 10.0.1.0/24
            |
            +-- EC2 / NGINX

ap-southeast-1
10.1.0.0/16
    |
    +-- Public Subnet 10.1.1.0/24
            |
            +-- EC2 / NGINX
```

There is no VPC peering, Transit Gateway, VPN, or other private network connection between the regional environments.

The two VPCs therefore represent separate network domains.

Each region also has its own:

* Internet Gateway.
* Public route table.
* Security group.
* EC2 instance.
* Regional Amazon Linux AMI lookup.

A network or instance-level change in one region does not automatically modify the equivalent resource in the other region.

## What Is Shared Across Regions

The EC2 instances use the same IAM role and instance profile for AWS Systems Manager.

The role is created through the primary AWS provider, but IAM is an account-level AWS service.

Conceptually:

```text
                    AWS Account
                        |
              Shared EC2 SSM Role
                 /             \
                /               \
     us-east-1 EC2         ap-southeast-1 EC2
```

This creates a different type of boundary from the VPC separation.

The workloads are regionally separated at the network and infrastructure layers, but their administrative AWS identity depends on a shared account-level IAM configuration.

A change to that role or its attached permissions can therefore affect instances in both regions.

The architecture should not treat regional deployment as equivalent to administrative isolation.

## Internet-to-Workload Boundary

Both EC2 instances operate in public subnets and receive public IP addresses.

HTTP traffic is permitted from:

`0.0.0.0/0`

on TCP port 80.

The implemented request path is therefore direct:

```text
Internet
   |
   +--> Security Group --> Public EC2 --> NGINX
```

There is no load balancer, CDN, WAF, reverse proxy tier, or other application-edge control between the Internet and the EC2 web server.

That is appropriate to the scope of this infrastructure lab, but it defines an important security boundary: the EC2 instance itself is directly exposed to allowed Internet traffic.

The project does not claim that this represents a production Internet-facing architecture.

## Administrative Boundary

Inbound SSH is not permitted by the web security groups.

Instead, the EC2 instances receive an IAM instance profile containing the AWS-managed `AmazonSSMManagedInstanceCore` policy.

This establishes the instance-side identity foundation for AWS Systems Manager administration.

The security path for administration is therefore different from the public application path.

Public application traffic reaches NGINX through TCP port 80.

Administrative access is intended to rely on AWS identity and Systems Manager rather than opening an SSH management port to the Internet.

The repository does not define the human IAM identities, roles, authentication controls, or authorization policies that determine which administrators may initiate Systems Manager sessions.

Those controls would be part of the broader account-level administrative architecture.

## Regional Failure Versus Global Service Availability

Deploying the workload in two regions creates two independent infrastructure footprints.

It does not by itself create automatic failover.

The current architecture has no global routing or health-decision layer that directs users between the two regions.

A user accesses either regional public IP independently.

Therefore:

```text
Two Regional Deployments ≠ Automated Multi-Region Failover
```

If the primary regional endpoint becomes unavailable, the existence of the secondary instance does not automatically redirect traffic to it.

A production architecture would require an additional decision point such as DNS-based routing, Global Accelerator, or another traffic-management mechanism combined with health evaluation and failover policy.

This is both a resilience boundary and a control boundary because some component must determine when traffic is allowed or directed toward another region.

## Configuration Consistency Boundary

Both regional environments are defined from the same Terraform configuration.

This reduces configuration drift by expressing equivalent infrastructure patterns through one codebase.

It also creates a shared change boundary.

A Terraform change can affect infrastructure in both regions during the same deployment operation.

That means multi-region independence at runtime does not imply independent infrastructure-change authority.

A production design may need additional controls around:

* Terraform state protection.
* Change approval.
* Deployment authorization.
* Regional rollout sequencing.
* Plan review.
* Rollback.
* Separation of development and production environments.

Those governance controls are outside the implemented scope of this repository.

## Failure Paths That Matter

### Shared IAM Misconfiguration

Because both instances use the same Systems Manager IAM role, excessive permissions or an incorrect role change could affect administrative capability in both regions.

Regional VPC separation would not contain that account-level identity issue.

### Direct Internet Exposure

The web servers accept HTTP directly from the Internet.

The security groups limit the exposed service to TCP port 80, but there is no implemented application-edge inspection or filtering layer.

### Unrestricted Outbound Traffic

The EC2 security groups permit outbound traffic to `0.0.0.0/0`.

The project does not implement workload-specific egress restrictions.

### Regional Deployment Error

Because one Terraform configuration manages both environments, an incorrect infrastructure change could potentially affect resources in both regions.

### False Assumption of Failover

The secondary region may appear to provide resilience, but no automated mechanism currently directs users to it if the primary endpoint fails.

Treating deployment redundancy as operational failover would overstate the architecture.

## Boundaries a Production Global Application Would Add

A production implementation would introduce additional security and operational boundaries depending on business requirements.

Examples include:

* Global DNS or traffic-management decisions.
* Health-based regional failover.
* TLS termination and certificate management.
* WAF and application-edge filtering.
* Load balancers separating public entry points from compute.
* Private application subnets.
* Auto Scaling and Multi-AZ deployment.
* Centralized logging and security monitoring.
* Vulnerability and patch governance.
* Workload-specific egress controls.
* Administrative IAM and privileged-access governance.
* Infrastructure deployment approvals.
* Protected Terraform state.
* Environment separation.
* Backup and recovery requirements.

These are additional architecture considerations and are not implemented by the current Terraform.

## Architecture Takeaway

The important boundary in this project is not simply the line between two AWS regions.

The architecture contains two different kinds of separation:

**Regional infrastructure is separated through independent VPCs, subnets, routing, security groups, and EC2 instances.**

**Administrative identity remains connected through shared account-level IAM resources.**

At the same time, the two deployments do not become a global service until another control layer makes routing, health, and failover decisions.

That distinction prevents three common assumptions:

**Multi-region deployment does not automatically provide global routing.**

**Regional network separation does not automatically provide administrative isolation.**

**Infrastructure redundancy does not automatically provide operational failover.**

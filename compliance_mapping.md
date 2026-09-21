# Security and Compliance Alignment

## Purpose

This document identifies security practices demonstrated by the architecture and relates them to common security frameworks.

The mappings are provided for architecture discussion and learning purposes. They do not represent certification, formal compliance validation, or a complete implementation of any framework.

## NIST SP 800-53 Alignment

| Control Area | Reference | Architecture Alignment |
|---|---|---|
| Network Protection | SC-7 | Separate regional VPCs, subnets, security groups, and controlled ingress establish network boundaries. |
| Least Privilege | AC-6 | EC2 instances receive an IAM role specifically for Systems Manager access rather than broad administrative credentials. |
| Remote Access | AC-17 | Systems Manager provides the administrative-access foundation without exposing inbound SSH. |
| System Configuration | CM-2 | Terraform defines a repeatable infrastructure baseline for both AWS regions. |
| System Monitoring | SI-4 | Monitoring is identified as a required production extension; centralized monitoring and alerting are not implemented in the current lab. |

## ISO/IEC 27001 Alignment

The architecture supports security practices associated with:

- Identity and access management
- Network security
- Configuration management
- Secure administration
- Infrastructure standardization
- Logging and monitoring planning

The current lab demonstrates supporting technical controls but does not constitute an ISO/IEC 27001 implementation or certification.

## Security Architecture Practices Demonstrated

### Reduced Administrative Exposure

Inbound SSH is not opened by the EC2 security groups. Systems Manager IAM permissions establish an alternative administrative-access path.

### Regional Network Separation

The primary and secondary environments use independent VPCs and non-overlapping CIDR ranges.

### Infrastructure as Code

Terraform provides a version-controlled and repeatable definition of the regional infrastructure.

### Explicit Control Boundaries

The project distinguishes implemented controls from production capabilities that would still need to be designed, including TLS, WAF protection, centralized logging, monitoring, automated failover, and global traffic management.

## Scope

This mapping applies only to the controls demonstrated by the Terraform configuration in this repository.

Additional technical controls, operating procedures, evidence collection, governance processes, testing, and organizational controls would be required for formal compliance.

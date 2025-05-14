# Compliance Mapping

This project supports the following compliance-aligned practices:

| Control Area         | Standard         | Control Reference       | Implementation Example                             |
|----------------------|------------------|--------------------------|-----------------------------------------------------|
| Network Segmentation | NIST 800-53      | SC-7                     | VPCs and subnets split by region                    |
| Access Control       | NIST 800-53      | AC-2, AC-6               | IAM roles and SSM for least-privilege access        |
| Logging & Monitoring | ISO 27001: A.12  | A.12.4.1                 | SSM/CloudWatch ready EC2 instances                  |
| Secure Configuration | PCI-DSS v4       | Req. 2.2, 2.2.1          | Hardened NGINX setup using EC2 user_data            |
| Remote Access        | CIS AWS Benchmark| 4.1, 4.2, 4.3            | SSM preferred over SSH, SSH scoped to your IP only  |

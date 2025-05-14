# Global Web App Terraform Deployment

This project provisions a globally distributed web application with:

- Two VPCs (US-East-1 and AP-Southeast-1)
- Public subnets and IGWs
- EC2 instances running NGINX
- SSM access for secure remote administration
- Security Groups scoped to allow HTTPS and SSH

## Deployment Steps

```bash
terraform init
terraform apply
```

## Teardown

```bash
terraform destroy
```

## Outputs

- `area1_public_ip` — EC2 in US-East-1
- `area2_public_ip` — EC2 in AP-Southeast-1

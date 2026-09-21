# Teardown Instructions

The Terraform configuration for this project is located in the `terraform/` directory.

From the repository root:

```bash
cd terraform
terraform plan -destroy
terraform destroy
```

Review the destroy plan before confirming the operation.

## Verify Cleanup

After Terraform completes, verify that resources have been removed from both configured AWS regions:

- `us-east-1`
- `ap-southeast-1`

Terraform can only destroy resources represented in its state. If resources were manually changed or created outside this configuration, additional cleanup may be required.

Always verify the AWS environment after teardown to avoid leaving unnecessary resources running and incurring charges.

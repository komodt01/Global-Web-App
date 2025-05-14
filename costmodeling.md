
# Cost Modeling

- **EC2 t3.small** on-demand (regional pricing)
- **CloudFront**: First 1TB/month tier estimated
- **Route 53**: Hosted zone + health check pricing
- **S3 for logs** (optional) + tiered storage (planned)

## Optimization Recommendations
- Use S3 lifecycle rules for future log storage
- Evaluate EC2 Savings Plans
- Tune CloudFront cache TTLs

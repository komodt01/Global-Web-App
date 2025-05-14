# CloudWatch Monitoring Notes

This project includes **example** CloudWatch alarms to demonstrate how basic monitoring can be implemented using Terraform.

## Included Alarms

- `HighCPU-GlobalApp-Area1` — monitors average CPU utilization for Area 1 EC2
- `HighCPU-GlobalApp-Area2` — monitors average CPU utilization for Area 2 EC2

## Alarm Parameters

- **Metric**: CPUUtilization
- **Threshold**: > 70%
- **Evaluation Period**: 2 x 2-minute intervals
- **Action**: No notification target included (SNS can be added)

## Important Notes

⚠️ These alarms are for demonstration purposes only.

In a production environment, you should also consider:
- **Disk, Memory, and Network** metrics via the CloudWatch Agent
- **Log monitoring** (e.g., app/server logs)
- **Custom metrics** (business KPIs, error rates, etc.)
- **Alerting via Amazon SNS** or integration with Slack, PagerDuty, etc.
- **CloudWatch Dashboards** for real-time visualization

Use these templates as a starting point for more robust observability.


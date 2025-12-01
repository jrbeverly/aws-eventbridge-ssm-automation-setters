# AWS EventBridge SSM Automation Setters

> [!WARNING]
> **AI-authored:** This change was autonomously planned and implemented by an AI software factory from a human-authored specification, with possible subsequent human review or modification.

Tests fanning a one-call AWS "setter" out to explicit account/region targets using no custom code. EventBridge starts a Step Functions workflow, which reads a target manifest from S3 and starts a multi-account SSM Automation (`TargetLocations`). The reference runbook sets the Parameter Store high-throughput service setting and asserts the new value.

```sh
cd env/workflow-hosting-account
terraform init && terraform apply -var enable_scheduled_enforcement=false
echo '{"targets":[{"account_id":"<acct>","regions":["us-west-2"]}]}' | aws s3 cp - s3://$(terraform output -raw manifest_bucket)/manifests/fleet.json

terraform apply -var 'enforcement_schedule=rate(1 minute)'
aws ssm reset-service-setting --setting-id /ssm/parameter-store/high-throughput-enabled
terraform destroy
```

## Notes

- reviewed; probably not pursuing this direction
- some neat elements; not especially interested in taking it further
- basic ideas are there; fundamental challenges remain
- next iteration needs more work on defining what actually makes a good system work

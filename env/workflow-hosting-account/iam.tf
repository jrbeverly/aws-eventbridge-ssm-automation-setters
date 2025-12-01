# Step Functions orchestrator.
resource "aws_iam_role" "orchestrator" {
  name = "AutomationSettersOrchestratorRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "states.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy" "orchestrator" {
  role = aws_iam_role.orchestrator.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.manifests.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:StartAutomationExecution",
          "ssm:GetAutomationExecution",
          "ssm:DescribeAutomationStepExecutions",
        ]
        Resource = [
          "arn:aws:ssm:${local.region}:${local.account_id}:document/${aws_ssm_document.high_throughput.name}",
          "arn:aws:ssm:${local.region}:${local.account_id}:automation-definition/*",
          "arn:aws:ssm:${local.region}:${local.account_id}:automation-execution/*",
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = "arn:aws:iam::*:role/${local.target_execution_role}"
      },
    ]
  })
}

# Target execution role. The parent Automation execution runs as this role in the home
# account (AutomationAssumeRole resolves {{global:ACCOUNT_ID}} there too) and assumes the
# same role name in each target account. Other target accounts need their own copy.
resource "aws_iam_role" "target_execution" {
  name = local.target_execution_role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Principal = { AWS = "arn:aws:iam::${local.account_id}:root" }, Action = "sts:AssumeRole" },
      { Effect = "Allow", Principal = { Service = "ssm.amazonaws.com" }, Action = "sts:AssumeRole" },
    ]
  })
}

resource "aws_iam_role_policy" "target_execution" {
  role = aws_iam_role.target_execution.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ssm:UpdateServiceSetting", "ssm:GetServiceSetting"]
        Resource = "arn:aws:ssm:*:*:servicesetting/ssm/parameter-store/high-throughput-enabled"
      },
      {
        Effect   = "Allow"
        Action   = ["ssm:StartAutomationExecution", "ssm:GetAutomationExecution", "ssm:DescribeAutomationExecutions"]
        Resource = "*"
      },
      { Effect = "Allow", Action = "iam:PassRole", Resource = "arn:aws:iam::*:role/${local.target_execution_role}" },
      { Effect = "Allow", Action = "sts:AssumeRole", Resource = "arn:aws:iam::*:role/${local.target_execution_role}" },
    ]
  })
}

resource "aws_sfn_state_machine" "enforcement" {
  name       = "automation-setters-enforcement"
  role_arn   = aws_iam_role.orchestrator.arn
  definition = file("${path.module}/../../orchestration/scheduled-enforcement.asl.json")
}

resource "aws_iam_role" "eventbridge_sfn" {
  name = "AutomationSettersEventBridgeSfnRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "events.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy" "eventbridge_sfn" {
  role = aws_iam_role.eventbridge_sfn.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = "states:StartExecution", Resource = aws_sfn_state_machine.enforcement.arn }]
  })
}

resource "aws_cloudwatch_event_rule" "enforcement" {
  name                = "automation-setters-enforcement"
  schedule_expression = var.enforcement_schedule
  state               = var.enable_scheduled_enforcement ? "ENABLED" : "DISABLED"
}

resource "aws_cloudwatch_event_target" "enforcement" {
  rule     = aws_cloudwatch_event_rule.enforcement.name
  arn      = aws_sfn_state_machine.enforcement.arn
  role_arn = aws_iam_role.eventbridge_sfn.arn
  input = jsonencode({
    operation  = aws_ssm_document.high_throughput.name
    manifest   = { bucket = aws_s3_bucket.manifests.id, key = var.manifest_key }
    parameters = var.parameters
  })
}

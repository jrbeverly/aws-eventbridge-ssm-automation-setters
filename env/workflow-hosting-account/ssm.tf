resource "aws_ssm_document" "high_throughput" {
  name            = "ssm-parameter-store-high-throughput"
  document_type   = "Automation"
  document_format = "YAML"
  content         = file("${path.module}/../../runbooks/ssm-parameter-store-high-throughput.yaml")
}

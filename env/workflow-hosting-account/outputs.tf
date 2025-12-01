output "state_machine_arn" {
  value = aws_sfn_state_machine.enforcement.arn
}

output "manifest_bucket" {
  value = aws_s3_bucket.manifests.id
}

variable "home_region" {
  type    = string
  default = "us-west-2"
}

variable "enable_scheduled_enforcement" {
  type    = bool
  default = true
}

variable "enforcement_schedule" {
  type    = string
  default = "rate(1 day)"
}

variable "manifest_key" {
  type    = string
  default = "manifests/fleet.json"
}

variable "parameters" {
  type    = map(string)
  default = { Enabled = "true" }
}

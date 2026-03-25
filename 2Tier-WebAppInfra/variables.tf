variable "tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default = {
    project     = "2Tier-WebApp",
    environment = "dev"
  }
}

variable "region" {
  description = "aws region to deploy to"
  type        = string
  default     = "eu-west-2"
}
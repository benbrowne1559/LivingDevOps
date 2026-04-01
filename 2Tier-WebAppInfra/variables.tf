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
  //default  = "eu-north-1"
}

variable "db_name" {
  description = "name of postgres db"
  type        = string
  default     = "postgresdb"
}

variable "ssl_cert" {
  description = "ssl cert arn"
  type        = string
  default     = "arn:aws:acm:eu-west-2:628132821277:certificate/9528f81b-030c-41e8-bc1b-707ae6a41672"
}

variable "container_name" {
  description = "name of app container"
  type        = string
  default     = "webapp"
}

variable "container_port" {
  description = "app container port"
  type        = number
  default     = 5000
}

variable "image_tag" {
  description = "image tag full"
  type        = string
  default     = "628132821277.dkr.ecr.eu-west-2.amazonaws.com/benbo/webapp:1.0"
}

variable "private-rds-subnet" {
  description = "rds subnet map"
  type = list(object({
    cidr_block = string
    avail_zone = string
  }))
  default = [{
    cidr_block = "10.0.5.0/24"
    avail_zone = "eu-west-2a"
  },
  {
  cidr_block = "10.0.7.0/24"
  avail_zone = "eu-west-2b"
  },
  ]
}

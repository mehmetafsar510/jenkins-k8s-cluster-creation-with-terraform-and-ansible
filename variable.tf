variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "AWS_REGION" {
  default = "us-east-1"
}

variable "key_name" {
  type    = string
  default = "the-doctor.pem"
}

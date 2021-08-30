variable "name" {
  description = "The name of the faasd instance."
  type        = string
}

variable "basic_auth_user" {
  description = "The basic auth user name."
  type        = string
  default     = "admin"
}

variable "basic_auth_password" {
  description = "The basic auth password, if left empty, a random password is generated."
  type        = string
  default     = null
  sensitive   = true
}

variable "domain" {
  description = "A public domain for the faasd instance. This will the use of Caddy and a Let's Encrypt certificate"
  type        = string
  default     = ""
}

variable "email" {
  description = "Email used to order a certificate from Let's Encrypt"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "subnet_id" {
  description = "VPC Subnet ID to launch in."
  type        = string
}

variable "aws_instance" {
  description = "The instance type to use for the instance."
  type        = string
  default     = "t2.small"
}
variable "key_name" {
  description = "Key name of the Key Pair to use for the instance."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

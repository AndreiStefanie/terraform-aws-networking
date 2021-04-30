variable "aws_region" {}

variable "cidr_block" {
  default = "10.123.0.0/16"
}

variable "public_sn_count" {
  default = 2
}

variable "public_cidrs" {
  default = ["10.123.1.0/24", "10.123.3.0/24"]
}

variable "private_sn_count" {
  default = 3
}

variable "private_cidrs" {
  default = ["10.123.2.0/24", "10.123.4.0/24", "10.123.6.0/24"]
}

variable "access_ip" {}

variable "db_subnet_group" {
  default = true
}

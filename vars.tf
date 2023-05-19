variable "region_names" {
  type = list(string)
  default = [
    "us-east-1",
    "us-west-1"
  ]
}

variable "availability_zone_names" {
  type    = list(string)
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
    "us-west-1a",
    "us-west-1b",
    "us-west-1c"
  ]
}

variable "aims" {
  type = map(string)
  default = {
    us-east-1 = "ami-007855ac798b5175e"
    us-west-1 = "ami-014d05e6b24240371"
  }
}

variable "PRIVATE_KEY_PATH" {
  default = "default-region-key-pair"
}

variable "PUBLIC_KEY_PATH" {
  default = "default-region-key-pair.pub"
}

variable "EC2_USER" {
  default = "ubuntu"
}

variable "main_vpc_cidr" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "all_subnets" {}
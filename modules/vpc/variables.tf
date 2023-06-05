variable "region_name" {}
variable "main_vpc_cidr" {
  default = "172.31.0.0/16"
}
variable "public_subnets_cidr" {
  default = "172.31.1.0/16"
}
variable "private_subnets_cidr" {
  default = "172.31.2.0/16"
}
variable "all_subnets_cidr" {
  default = "0.0.0.0/0"
}
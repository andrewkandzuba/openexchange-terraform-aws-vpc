variable "instance_type" {
  default = "t2.micro"
}
variable "key_name" {
  default = "cda-key-pair"
}
variable "ec2-user" {
  default = "ec2-user"
}
variable "boot-script" {}
variable "cda_public_subnets" {
  type = list(string)
}
variable "cda_security_groups" {
  type = list(string)
}
variable "cda_availability_zones" {}
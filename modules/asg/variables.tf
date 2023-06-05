variable "instance_template_name" {
  default = "cda-instance-template"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "boot-script" {}
variable "cda_public_subnets" {
  type = list(string)
}
variable "cda_security_groups" {
  type = list(string)
}
variable "ami_id" {}
variable "cda_alb_tg_arn" {}

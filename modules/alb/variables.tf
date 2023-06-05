variable "alb_name" {
  default = "cda-alb"
}
variable "alb_tg_health_check" {
  type = map(string)
  default = {
    "timeout"  = "10"
    "interval" = "20"
    "path"     = "/"
    "port"     = "80"
    "unhealthy_threshold" = "2"
    "healthy_threshold" = "3"
  }
}
variable "all_subnets_cidr" {}
variable "cda_public_subnets" {
  type = list(string)
}
variable "cda_vpc_id" {}
variable "cda_instances" {
  type = list(string)
}
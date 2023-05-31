variable "region_name" {
  default = "us-east-1"
}

variable "availability_zones_by_region" {
  type = map(list(string))
  default = {
    us-east-1 = ["us-east-1a", "us-east-1b", "us-east-1c"]
    us-west-1 = ["us-west-1a", "us-west-1b", "us-west-1c"]
  }
}

variable "aims" {
  type = map(string)
  default = {
    us-east-1 = "ami-0bef6cc322bfff646"
    us-west-1 = "ami-04669a22aad391419"
  }
}

variable "private-key-path" {
  default = "default-region-key-pair"
}

variable "public-key-path" {
  default = "default-region-key-pair.pub"
}

variable "ec2-user" {
  default = "ec2-user"
}

variable "boot-script" {
  default = "ec2-user-data.sh"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "main_vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "public_subnets" {
  default = "10.0.1.0/16"
}
variable "private_subnets" {
  default = "10.0.2.0/16"
}
variable "all_subnets" {
  default = "0.0.0.0/0"
}
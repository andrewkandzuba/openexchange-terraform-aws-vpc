output "cda_public_subnets" {
  value = aws_subnet.cda_public_subnets[*].id
}
output "cda_vpc_id" {
  value = aws_vpc.cda_vpc.id
}
output "cda_availability_zones" {
  value = data.aws_availability_zones.available.names
}
output "all_subnets_cidr" {
  value = var.all_subnets_cidr
}
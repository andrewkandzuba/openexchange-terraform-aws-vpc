output "cda_instances" {
  value = aws_instance.cda-instance[*].id
}
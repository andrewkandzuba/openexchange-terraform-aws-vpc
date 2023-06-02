output "cda_instances" {
  value = aws_instance.cda_instance[*].id
}
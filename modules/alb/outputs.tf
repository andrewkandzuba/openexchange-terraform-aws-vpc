output "cda_alb_sg" {
  value = aws_security_group.alb_sg
}
output "cda_alb_tg_arn" {
  value = aws_lb_target_group.cad_alb_tg.arn
}
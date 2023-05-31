resource "aws_lb" "cda-alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for subnet in aws_subnet.cda-public-subnet : subnet.id]

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  # @ToDo: Logs in S3
  #access_logs {
  #  bucket  = aws_s3_bucket.lb_logs.id
  #  prefix  = "test-lb"
  #  enabled = true
  #}
}

resource "aws_lb_target_group" "cad-alb-tg" {
  vpc_id   = aws_vpc.cda-vpc.id
  target_type = "instance"

  name     = var.alb_tg["name"]
  port     = var.alb_tg["port"]
  protocol = var.alb_tg["protocol"]

  health_check {
    healthy_threshold   = var.alb_tg_health_check["healthy_threshold"]
    interval            = var.alb_tg_health_check["interval"]
    unhealthy_threshold = var.alb_tg_health_check["unhealthy_threshold"]
    timeout             = var.alb_tg_health_check["timeout"]
    path                = var.alb_tg_health_check["path"]
    port                = var.alb_tg_health_check["port"]
  }
}

resource "aws_lb_listener" "cda-alb-listener" {

  load_balancer_arn = aws_lb.cda-alb.arn
  port              = var.alb_tg["port"]
  protocol          = var.alb_tg["protocol"]

  default_action {
    target_group_arn = aws_lb_target_group.cad-alb-tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "cad-tg-at" {
  count = length(lookup(var.availability_zones_by_region, var.region_name))

  target_group_arn = aws_lb_target_group.cad-alb-tg.arn
  target_id        = aws_instance.cda-instance[count.index].id
}
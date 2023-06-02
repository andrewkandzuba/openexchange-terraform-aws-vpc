resource "aws_lb" "cda_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.cda_public_subnets

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  # @ToDo: Logs in S3
  #access_logs {
  #  bucket  = aws_s3_bucket.lb_logs.id
  #  prefix  = "test-lb"
  #  enabled = true
  #}
}

resource "aws_lb_target_group" "cad_alb_tg" {
  vpc_id   = var.cda_vpc_id
  target_type = "instance"

  name     = "cad-alb-tg-plain"
  port     = "80"
  protocol = "HTTP"

  health_check {
    healthy_threshold   = var.alb_tg_health_check["healthy_threshold"]
    interval            = var.alb_tg_health_check["interval"]
    unhealthy_threshold = var.alb_tg_health_check["unhealthy_threshold"]
    timeout             = var.alb_tg_health_check["timeout"]
    path                = var.alb_tg_health_check["path"]
    port                = var.alb_tg_health_check["port"]
  }
}

resource "aws_lb_listener" "cda_alb_listener_plain" {

  load_balancer_arn = aws_lb.cda_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.cad_alb_tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "cad_tg_at" {
  count = length(var.cda_public_subnets)

  target_group_arn = aws_lb_target_group.cad_alb_tg.arn
  target_id        = var.cda_instances[count.index]
}

resource "aws_security_group" "alb_sg" {
  vpc_id = var.cda_vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = var.all_subnets_cidr
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = var.all_subnets_cidr
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = var.all_subnets_cidr
  }

  tags = {
    Name = "cda-alb-sg"
  }
}

# Creating local self-signed certificate
locals {
  cn       = "openexchange.io"
  org      = "OpenExcnage"
  validity = 24 # This is approximatively 10 years
}

# Root Self Signed CA
resource "tls_private_key" "cda_root_ca" {
  algorithm = "RSA"
}
resource "tls_self_signed_cert" "cda_root_ca" {
  private_key_pem = tls_private_key.cda_root_ca.private_key_pem

  is_ca_certificate = true

  subject {
    common_name         = local.cn
    organization        = local.org
  }

  validity_period_hours = local.validity

  allowed_uses = [
    "cert_signing"
  ]
}

# Root Server-Side Signing Cert
resource "tls_private_key" "cda_server_root" {
  algorithm = "RSA"
}
resource "tls_cert_request" "cda_server_root" {
  private_key_pem = tls_private_key.cda_server_root.private_key_pem

  subject {
      common_name  = "*.${local.cn}"
  }
}
resource "tls_locally_signed_cert" "cda_server_root" {
  cert_request_pem = tls_cert_request.cda_server_root.cert_request_pem
  ca_private_key_pem = tls_private_key.cda_root_ca.private_key_pem
  ca_cert_pem = tls_self_signed_cert.cda_root_ca.cert_pem

  validity_period_hours = local.validity

  allowed_uses = [
    "cert_signing",
  ]
}

# Server Signed Cert
resource "tls_private_key" "cda_child" {
  algorithm   = "RSA"
}
resource "tls_cert_request" "cda_child" {
  private_key_pem = tls_private_key.cda_child.private_key_pem
  dns_names       = [ "elb.${local.cn}" ]

  subject {
    common_name = "elb.${local.cn}"
  }
}
resource "tls_locally_signed_cert" "cda_child" {
  cert_request_pem   = tls_cert_request.cda_child.cert_request_pem
  ca_private_key_pem = tls_private_key.cda_server_root.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.cda_server_root.cert_pem

  validity_period_hours = local.validity / 12 # valid for ~ 3 months

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "cda_alb_acm_cert" {
  private_key      = tls_private_key.cda_child.private_key_pem
  certificate_body = tls_locally_signed_cert.cda_child.cert_pem
}

resource "aws_lb_listener" "cda_alb_listener_ssl" {

  load_balancer_arn = aws_lb.cda_alb.arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cda_alb_acm_cert.arn

  default_action {
    target_group_arn = aws_lb_target_group.cad_alb_tg.arn
    type             = "forward"
  }
}
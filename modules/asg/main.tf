resource "aws_launch_template" "cda_launch_template" {
  name = var.instance_template_name

  image_id               = var.ami_id
  instance_type          = var.instance_type

  monitoring {
    enabled = true
  }

  # network_interfaces {
    # Public IP assignment
  #  associate_public_ip_address = true
  # }

  # Security Group
  vpc_security_group_ids = var.cda_security_groups

  # Root EBS volume
  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 2
    }
  }

  user_data = filebase64(var.boot-script)

  tags = {
    Name = "cda-instance"
  }
}

resource "aws_autoscaling_group" "cda_asg" {
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.cda_launch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.cda_public_subnets
  target_group_arns = [var.cda_alb_tg_arn]
}
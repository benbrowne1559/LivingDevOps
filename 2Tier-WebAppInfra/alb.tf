# App Load balancer
resource "aws_lb" "webapp-alb" {
  name               = "webapp-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public1-sn.id, aws_subnet.public2-sn.id]
  security_groups = [aws_security_group.allow-inbound-elb-sg.id]

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "http-listener" {
  load_balancer_arn = aws_lb.webapp-alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https-listener" {
  load_balancer_arn = aws_lb.webapp-alb.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_cert

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.ecs-tg.arn
      }
    }
  }
}


# IP Target Group

resource "aws_lb_target_group" "ecs-tg" {
  name        = "webapp-alb-tg"
  port        = 5000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.webapp-vpc.id

  health_check {
    enabled           = true
    path = "/"
    healthy_threshold = 2
  }


}
# Create a new load balancer
resource "aws_elb" "webapp-alb" {
  name               = "webapp-elb"
  availability_zones = ["eu-west-2a", "eu-west-2a"]

  access_logs {
    bucket        = "foo"
    bucket_prefix = "bar"
    interval      = 60
  }

  listener {
    instance_port     = 5000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 5000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:eu-north-1:628132821277:certificate/6b9401a9-f8e3-4e42-ad7d-3ae6bd7d64c0"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:5000/"
    interval            = 30
  }

  tags = var.tags
}

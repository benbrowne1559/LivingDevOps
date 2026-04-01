

resource "aws_route53_zone" "main" {
  name = "benbrownedevops.xyz"
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "benbrownedevops.xyz"
  type    = "A"

  alias {
    name                   = aws_lb.webapp-alb.dns_name
    zone_id                = aws_lb.webapp-alb.zone_id
    evaluate_target_health = true
  }
}

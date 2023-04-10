resource "aws_lb_listener" lg {
  load_balancer_arn = var.lb_arn
  port              = var.port
  protocol          = var.protocol
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = var.tg_arn
  }
}
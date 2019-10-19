resource "aws_elb" "my-elb" {
  name            = "my-elb"
  subnets         = var.SUBNETS
  security_groups = var.SECURITY_GRPS
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    interval            = 30
    target              = "HTTP:80/"
    timeout             = 3
    unhealthy_threshold = 2
  }

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 60
  tags = {
    Name = "my-elb"
  }
}


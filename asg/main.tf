resource "aws_launch_configuration" "asg_launch_conf" {
  image_id        = var.AMI_ID
  instance_type   = var.INSTANCE_TYPE
  key_name        = var.AWS_KEY
  security_groups = var.SECURITY_GRPS
  user_data       = var.FILE
}

resource "aws_autoscaling_group" "asg_example" {
  name                 = "asg_example"
  vpc_zone_identifier  = var.VPC_ZONE_IDENTIFIER
  launch_configuration = aws_launch_configuration.asg_launch_conf.name
  max_size             = var.MAX_SIZE
  min_size             = var.MIN_SIZE
  health_check_type    = var.HEALTHCHK_TYPE
  load_balancers       = var.LOAD_BALANCERS
  force_delete         = true

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "ec2 instance"
  }
}

resource "aws_autoscaling_policy" "cpu_scale_up" {
  autoscaling_group_name = aws_autoscaling_group.asg_example.name
  name                   = "cpu_scale_up"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "cpu_scale_down" {
  autoscaling_group_name = aws_autoscaling_group.asg_example.name
  name                   = "cpu_scale_down"
  scaling_adjustment     = -1
  cooldown               = 300
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_scaledup" {
  alarm_name          = "cpu_alarm_scaleup"
  alarm_description   = "cpu_alarm_scaleup"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.asg_example.name
  }

  actions_enabled = true
  alarm_actions = [
    aws_autoscaling_policy.cpu_scale_up.arn,
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_scaledown" {
  alarm_name          = "cpu_alarm_scaledown"
  alarm_description   = "cpu_alarm_scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 5
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.asg_example.name
  }

  actions_enabled = true
  alarm_actions = [
    aws_autoscaling_policy.cpu_scale_down.arn,
  ]
}


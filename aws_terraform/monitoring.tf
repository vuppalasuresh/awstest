resource "aws_cloudwatch_log_group" "flask_log_group" {
  name = "/ecs/flask-app-logs"
}

resource "aws_cloudwatch_metric_alarm" "flask_log_alarm" {
  alarm_name                = "flask-log-alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "IncomingLogEvents"
  namespace                 = "AWS/Logs"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "10"
  alarm_description         = "Trigger alarm when log is written more than 10 times in a minute"
  insufficient_data_actions = []

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.flask_log_group.name
  }

  actions_enabled = true
  alarm_actions   = ["arn:aws:sns:us-east-1:058264462530:MySNS"]
}

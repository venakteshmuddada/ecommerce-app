variable "region" {
  default = "us-east-1"
}

variable "vpc_id" {
  default = "vpc-045409f9dc02cd4e1"
}

variable "subnet_ids" {
  type = list(string)
  default = ["subnet-0a37cf861b1a56e2b", "subnet-0303a79a44a64c950"]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  type      = string
  sensitive = true
  description = "The password for the database. Use Secrets Manager in real setup."
}

resource "aws_cloudwatch_log_group" "backend_logs" {
  name = "/aws/codebuild/backend-build-logs"
}

resource "aws_cloudwatch_log_stream" "backend_log_stream" {
  log_group_name = aws_cloudwatch_log_group.backend_logs.name
  name           = "backend-stream"
}
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name                = "high-cpu-alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 80
  alarm_actions             = [aws_sns_topic.monitoring_alerts.arn]
  dimensions = {
    InstanceId = "i-xxxxxxxxxxxx"
  }
}


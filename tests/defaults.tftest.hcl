mock_provider "aws" {}

variables {
  cache_cluster_id    = "test-001"
  low_priority_alarm  = ["arn:aws:sns:us-east-1:111111111111:alerts_low"]
  high_priority_alarm = ["arn:aws:sns:us-east-1:111111111111:alerts_high"]
}

run "defaults" {
  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 5
    error_message = <<-EOM
    Did not create all expected alarms.
    Got ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].threshold == 60
    error_message = <<-EOM
    Incorrect alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].threshold}, expected 60
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].threshold == 90
    error_message = <<-EOM
    Incorrect alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].threshold}, expected 90
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_database_capacity_usage"].threshold == 60
    error_message = <<-EOM
    Incorrect alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].threshold}, expected 60
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_database_capacity_usage"].threshold == 90
    error_message = <<-EOM
    Incorrect alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].threshold}, expected 90
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_network_packets_per_second_allowance_exceeded"].threshold == 1
    error_message = <<-EOM
    Incorrect alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_network_packets_per_second_allowance_exceeded"].threshold}, expected 1
    EOM
  }
}

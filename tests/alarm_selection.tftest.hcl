mock_provider "aws" {}

variables {
  cache_cluster_id                        = "test-001"
  low_priority_alarm                      = ["arn:aws:sns:us-east-1:111111111111:alerts_low"]
  high_priority_alarm                     = ["arn:aws:sns:us-east-1:111111111111:alerts_high"]
  cpu_utilization_high_threshold          = null
  cpu_utilization_vhigh_threshold         = null
  database_capacity_usage_high_threshold  = null
  database_capacity_usage_vhigh_threshold = null

  network_packets_per_second_allowance_exceeded_vhigh_threshold = null
}

run "no_alarms" {
  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 0
    error_message = <<-EOM
    Unexpected alarms were created.
    Got ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}, expected none.
    EOM
  }
}

run "alarms" {
  variables {
    cpu_utilization_high_threshold  = 10
    cpu_utilization_vhigh_threshold = 20
  }

  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 2
    error_message = <<-EOM
    Did not create all expected alarms.
    Got ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].alarm_name == "ElastiCache ${var.cache_cluster_id} CPU Utilization High"
    error_message = <<-EOM
    Incorrect low priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].alarm_name} expected ${var.cache_cluster_id} CPU Utilization High
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].alarm_name == "ElastiCache ${var.cache_cluster_id} CPU Utilization Very High"
    error_message = <<-EOM
    Incorrect high priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].alarm_name} expected ${var.cache_cluster_id} Very CPU Utilization High
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].alarm_description == "${var.cache_cluster_id} CPU Utilization is above ${var.cpu_utilization_high_threshold}%"
    error_message = <<-EOM
    Incorrect low priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].alarm_description} expected ${var.cache_cluster_id} CPU Utilization is above ${var.cpu_utilization_high_threshold}%
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].alarm_description == "${var.cache_cluster_id} CPU Utilization is above ${var.cpu_utilization_vhigh_threshold}%"
    error_message = <<-EOM
    Incorrect high priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].alarm_description} expected ${var.cache_cluster_id} CPU Utilization is above ${var.cpu_utilization_vhigh_threshold}%
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].threshold == var.cpu_utilization_high_threshold
    error_message = <<-EOM
    Incorrect low priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].threshold}, expected ${var.cpu_utilization_high_threshold}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].threshold == var.cpu_utilization_vhigh_threshold
    error_message = <<-EOM
    Incorrect high priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].threshold}, expected ${var.cpu_utilization_vhigh_threshold}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].alarm_actions == toset(var.low_priority_alarm)
    error_message = <<-EOM
    Incorrect low priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].alarm_actions)}, expected ${join(", ", var.low_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].alarm_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].alarm_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].ok_actions == toset(var.low_priority_alarm)
    error_message = <<-EOM
    Incorrect low priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].ok_actions)}, expected ${join(", ", var.low_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].ok_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].ok_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }
}

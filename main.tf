# Copyright 2023 Teak.io, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4, < 6"
    }
  }
}

locals {
  var_map = {
    cpu_utilization = {
      low_value          = var.cpu_utilization_high_threshold
      high_value         = var.cpu_utilization_vhigh_threshold
      metric_postfix     = "%"
      metric_description = "CPU Utilization"
      metric_name        = "CPUUtilization"
      directionality     = "high"
    },
    database_capacity_usage = {
      low_value          = var.database_capacity_usage_high_threshold
      high_value         = var.database_capacity_usage_vhigh_threshold
      metric_description = "Database Capacity Usage"
      metric_postfix     = "%"
      metric_name        = "DatabaseCapacityUsagePercentage"
      directionality     = "high"
    },
    replication_lag = {
      low_value          = var.replication_lag_high_threshold
      high_value         = var.replication_lag_vhigh_threshold
      metric_description = "Replication Lag"
      metric_name        = "ReplicationLag"
      metric_postfix     = " seconds"
      directionality     = "high"
    },
    network_packets_per_second_allowance_exceeded = {
      low_value          = var.network_packets_per_second_allowance_exceeded_high_threshold
      high_value         = var.network_packets_per_second_allowance_exceeded_vhigh_threshold
      metric_description = "Network Packets Per Second Allowance Exceeded"
      metric_name        = "NetworkPacketsPerSecondAllowanceExceeded"
      directionality     = "high"
    }
  }

  low_priority_alarms  = { for key, value in local.var_map : "low_${key}" => merge(value, { level = "", value = value["low_value"] }) if value["low_value"] != null }
  high_priority_alarms = { for key, value in local.var_map : "high_${key}" => merge(value, { level = "high", value = value["high_value"] }) if value["high_value"] != null }
  alarms               = merge(local.low_priority_alarms, local.high_priority_alarms)
}

resource "aws_cloudwatch_metric_alarm" "alarms" {
  for_each = local.alarms

  alarm_name = join(
    " ",
    compact([
      "ElastiCache cluster id",
      var.cache_cluster_id,
      each.value["metric_description"],
      each.value["level"] == "high" ? "Very" : null,
      each.value["directionality"] == "high" ? "High" : "Low"
    ])
  )
  alarm_description = "${var.cache_cluster_id} ${each.value["metric_description"]} is ${each.value["directionality"] == "high" ? "above" : "below"} ${each.value["value"]}${try(each.value["metric_postfix"], "")}"

  metric_name = each.value["metric_name"]
  namespace   = "AWS/ElastiCache"

  comparison_operator = each.value["directionality"] == "high" ? "GreaterThanOrEqualToThreshold" : "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  statistic           = "Average"
  period              = "300"
  threshold           = each.value["value"]

  alarm_actions = each.value["level"] == "high" ? var.high_priority_alarm : var.low_priority_alarm
  ok_actions    = each.value["level"] == "high" ? var.high_priority_alarm : var.low_priority_alarm

  tags = var.tags
}

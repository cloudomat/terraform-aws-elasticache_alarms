# Copyright 2024 Teak.io, Inc.
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

variable "cache_cluster_id" {
  type        = string
  description = "The identifier of the cache cluster for alarming"
}

variable "low_priority_alarm" {
  type        = list(string)
  description = "The actions to trigger on a low priority alarm"
}

variable "high_priority_alarm" {
  type        = list(string)
  description = "The actions to trigger on a high priority alarm"
}

variable "cpu_utilization_high_threshold" {
  type        = number
  default     = 60
  description = "How much cpu can be consumed until a low priority alert is triggered? Set to null to disable."
}

variable "cpu_utilization_vhigh_threshold" {
  type        = number
  default     = 90
  description = "How much cpu can be consumed until a high priority alert is triggered? Set to null to disable."
}

variable "database_capacity_usage_high_threshold" {
  type        = number
  default     = 60
  description = "How much capacity can be consumed until a low priority alert is triggered? Set to null to disable."
}

variable "database_capacity_usage_vhigh_threshold" {
  type        = number
  default     = 90
  description = "How much capacity can be consumed until a high priority alert is triggered? Set to null to disable."
}

variable "replication_lag_high_threshold" {
  type = number
  default = null
  description = "How far behind can a replica be in seconds before a low priority alert is triggered? Set to null to disable."
}

variable "replication_lag_vhigh_threshold" {
  type = number
  default = null
  description = "How far behind can a replica be in seconds before a high priority alert is triggered? Set to null to disable."
}

variable "network_packets_per_second_allowance_exceeded_high_threshold" {
  type = number
  default = null
  description = "How many network packets can be dropped due to rate limits before a low priority alert is triggered? Set to null to disable."
}

variable "network_packets_per_second_allowance_exceeded_vhigh_threshold" {
  type = number
  default = 1
  description = "How many network packets can be dropped due to rate limits before a high priority alert is triggered? Set to null to disable."
}

variable "tags" {
  type    = map(any)
  default = {}
}

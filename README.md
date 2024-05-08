# Elasticache Alerts

This module creates CloudWatch alerts for ElastiCache clusters.

Each supported metric can be given two thresholds. The first threshold will trigger a "low priority" alarm. This is intended for early notification of unusual system behavior or known potential issues, such as running out of database capacity. The second threshold will trigger a "high priority" alarm. This is intended for situations which require immediate attention and may indicate that downtime of the ElastiCache cluster or services using the cluster is imminent.

## Installation

This is a complete example of a minimal set of alarms.

```hcl
provider "aws" {}

variable "replication_group_id" {
  type        = string
  description = "The identifier of an ElastiCache replication group to monitor."
}

data "aws_elasticache_replication_group" "group" {
  replication_group_id = var.replication_group_id
}

module "alarms" {
  source = "cloudomat/elasticache_alerts/aws"

  for_each = data.aws_elasticache_replication_group.group.member_clusters

  cache_cluster_id = each.key

  low_priority_alarm  = []
  high_priority_alarm = []
}
```

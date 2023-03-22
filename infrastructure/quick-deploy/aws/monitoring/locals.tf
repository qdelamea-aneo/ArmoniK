data "aws_caller_identity" "current" {}

resource "random_string" "random_resources" {
  length  = 5
  special = false
  upper   = false
  numeric = true
}

resource "time_static" "creation_date" {}

locals {
  random_string             = random_string.random_resources.result
  suffix                    = var.suffix != null && var.suffix != "" ? var.suffix : local.random_string
  cluster_name              = try(var.eks.name, "")
  kms_name                  = "armonik-kms-monitoring-${local.suffix}-${local.random_string}"
  cloudwatch_log_group_name = "/aws/containerinsights/${local.cluster_name}/application"
  tags = merge(var.tags, {
    "application"        = "armonik"
    "deployment version" = local.suffix
    "created by"         = data.aws_caller_identity.current.arn
    "creation date"      = time_static.creation_date.rfc3339
  })

  # Seq
  seq_enabled            = tobool(try(var.monitoring.seq.enabled, false))
  seq_image              = try(var.monitoring.seq.image, "${data.aws_caller_identity.current.id}.dkr.ecr.eu-west-3.amazonaws.com/seq")
  seq_tag                = try(var.monitoring.seq.tag, "2021.4")
  seq_port               = try(var.monitoring.seq.port, 8080)
  seq_image_pull_secrets = try(var.monitoring.seq.image_pull_secrets, "")
  seq_service_type       = try(var.monitoring.seq.service_type, "LoadBalancer")
  seq_node_selector      = try(var.monitoring.seq.node_selector, {})
  seq_system_ram_target  = try(var.monitoring.seq.system_ram_target, 0.2)

  # Grafana
  grafana_enabled            = tobool(try(var.monitoring.grafana.enabled, false))
  grafana_image              = try(var.monitoring.grafana.image, "${data.aws_caller_identity.current.id}.dkr.ecr.eu-west-3.amazonaws.com/grafana")
  grafana_tag                = try(var.monitoring.grafana.tag, "latest")
  grafana_port               = try(var.monitoring.grafana.port, 3000)
  grafana_image_pull_secrets = try(var.monitoring.grafana.image_pull_secrets, "")
  grafana_service_type       = try(var.monitoring.grafana.service_type, "LoadBalancer")
  grafana_node_selector      = try(var.monitoring.grafana.node_selector, {})

  # node exporter
  node_exporter_enabled            = tobool(try(var.monitoring.node_exporter.enabled, false))
  node_exporter_image              = try(var.monitoring.node_exporter.image, "${data.aws_caller_identity.current.id}.dkr.ecr.eu-west-3.amazonaws.com/node-exporter")
  node_exporter_tag                = try(var.monitoring.node_exporter.tag, "latest")
  node_exporter_image_pull_secrets = try(var.monitoring.node_exporter.image_pull_secrets, "")
  node_exporter_node_selector      = try(var.monitoring.node_exporter.node_selector, {})

  # Prometheus
  prometheus_image               = try(var.monitoring.prometheus.image, "${data.aws_caller_identity.current.id}.dkr.ecr.eu-west-3.amazonaws.com/prometheus")
  prometheus_tag                 = try(var.monitoring.prometheus.tag, "latest")
  prometheus_image_pull_secrets  = try(var.monitoring.prometheus.image_pull_secrets, "")
  prometheus_service_type        = try(var.monitoring.prometheus.service_type, "ClusterIP")
  prometheus_node_exporter_image = try(var.monitoring.prometheus.node_exporter.image, "${data.aws_caller_identity.current.id}.dkr.ecr.eu-west-3.amazonaws.com/node-exporter")
  prometheus_node_exporter_tag   = try(var.monitoring.prometheus.node_exporter.tag, "latest")
  prometheus_node_selector       = try(var.monitoring.prometheus.node_selector, {})

  # Metrics exporter
  metrics_exporter_image              = try(var.monitoring.metrics_exporter.image, "${data.aws_caller_identity.current.id}.dkr.ecr.eu-west-3.amazonaws.com/metrics-exporter")
  metrics_exporter_tag                = try(var.monitoring.metrics_exporter.tag, "0.11.1")
  metrics_exporter_image_pull_secrets = try(var.monitoring.metrics_exporter.image_pull_secrets, "")
  metrics_exporter_service_type       = try(var.monitoring.metrics_exporter.service_type, "ClusterIP")
  metrics_exporter_node_selector      = try(var.monitoring.metrics_exporter.node_selector, {})
  metrics_exporter_extra_conf         = try(var.monitoring.metrics_exporter.extra_conf, {})

  # Partition metrics exporter
  partition_metrics_exporter_image              = try(var.monitoring.partition_metrics_exporter.image, "${data.aws_caller_identity.current.id}.dkr.ecr.eu-west-3.amazonaws.com/partition-metrics-exporter")
  partition_metrics_exporter_tag                = try(var.monitoring.partition_metrics_exporter.tag, "0.11.1")
  partition_metrics_exporter_image_pull_secrets = try(var.monitoring.partition_metrics_exporter.image_pull_secrets, "")
  partition_metrics_exporter_service_type       = try(var.monitoring.partition_metrics_exporter.service_type, "ClusterIP")
  partition_metrics_exporter_node_selector      = try(var.monitoring.partition_metrics_exporter.node_selector, {})
  partition_metrics_exporter_extra_conf         = try(var.monitoring.partition_metrics_exporter.extra_conf, {})

  # CloudWatch
  cloudwatch_enabled           = tobool(try(var.monitoring.cloudwatch.enabled, false))
  cloudwatch_kms_key_id        = try(var.monitoring.cloudwatch.kms_key_id, "")
  cloudwatch_retention_in_days = tonumber(try(var.monitoring.cloudwatch.retention_in_days, 30))

  # Fluent-bit
  fluent_bit_image              = try(var.monitoring.fluent_bit.image, "${data.aws_caller_identity.current.id}.dkr.ecr.eu-west-3.amazonaws.com/fluent-bit")
  fluent_bit_tag                = try(var.monitoring.fluent_bit.tag, "1.3.11")
  fluent_bit_image_pull_secrets = try(var.monitoring.fluent_bit.image_pull_secrets, "")
  fluent_bit_is_daemonset       = tobool(try(var.monitoring.fluent_bit.is_daemonset, false))
  fluent_bit_http_port          = tonumber(try(var.monitoring.fluent_bit.http_port, 0))
  fluent_bit_read_from_head     = tobool(try(var.monitoring.fluent_bit.read_from_head, true))
  fluent_bit_node_selector      = try(var.monitoring.fluent_bit.node_selector, {})

  # S3 for logs
  s3_logs_name                                 = var.s3_logs != null ? "${var.s3_logs.name}-${local.suffix}" : ""
  iam_s3_logs_decrypt_s3_policy_name           = "s3-logs-encrypt-decrypt-${local.suffix}"
  s3_logs_kms_key_id                           = (can(coalesce(var.s3_logs.kms_key_id)) ? var.s3_logs.kms_key_id : module.kms.0.arn)
}

output "prometheus_ebs_type" {
  value = aws_ebs_volume.prometheus_data.type
}

output "prometheus_tag_Name" {
  value = aws_ebs_volume.prometheus_data.tags.Name
}

output "grafana_ebs_type" {
  value = aws_ebs_volume.grafana_data.type
}

output "grafana_tag_Name" {
  value = aws_ebs_volume.grafana_data.tags.Name
}

output "loki_ebs_type" {
  value = aws_ebs_volume.loki_data.type
}

output "loki_tag_Name" {
  value = aws_ebs_volume.loki_data.tags.Name
}

output "tempo_ebs_type" {
  value = aws_ebs_volume.tempo_data.type
}

output "tempo_tag_Name" {
  value = aws_ebs_volume.tempo_data.tags.Name
}

output "kafka_ebs_type" {
  value = aws_ebs_volume.kafka_data.type
}

output "kafka_tag_Name" {
  value = aws_ebs_volume.kafka_data.tags.Name
}

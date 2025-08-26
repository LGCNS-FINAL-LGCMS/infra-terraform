output "jenkins_ebs_type" {
  value = aws_ebs_volume.jenkins_data.type
}

output "jenkins_tag_Name" {
  value = aws_ebs_volume.jenkins_data.tags.Name
}

output "kafka_ebs_type" {
  value = aws_ebs_volume.kafka_data.type
}

output "kafka_tag_Name" {
  value = aws_ebs_volume.kafka_data.tags.Name
}

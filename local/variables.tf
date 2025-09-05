variable "backend_auth_chart_version" {
  description = "backend auth server chart version"
  type        = string
}

variable "backend_member_chart_version" {
  description = "backend member server chart version"
  type        = string
}

variable "backend_lecture_chart_version" {
  description = "backend lecture server chart version"
  type        = string
}

variable "backend_core_chart_version" {
  description = "backend core server chart version"
  type        = string
}

variable "backend_guide_chart_version" {
  description = "backend guide server chart version"
  type        = string
}

variable "backend_lesson_chart_version" {
  description = "backend lesson server chart version"
  type        = string
}

variable "backend_upload_chart_version" {
  description = "backend upload server chart version"
  type        = string
}

variable "backend_consulting_chart_version" {
  description = "backend consulting server chart version"
  type        = string
}

variable "backend_leveltest_chart_version" {
  description = "backend leveltest server chart version"
  type        = string
}

variable "backend_payment_chart_version" {
  description = "backend payment server chart version"
  type        = string
}

variable "backend_streaming_chart_version" {
  description = "backend streaming server chart version"
  type        = string
}

variable "backend_notification_chart_version" {
  description = "backend notification server chart version"
  type        = string
}

variable "backend_tutor_chart_version" {
  description = "backend tutor server chart version"
  type        = string
}

variable "my_ip" {
  description = "my nat ip address"
  type        = string
}

variable "postgres_port" {
  description = "postgres port"
  type        = number
}

variable "valkey_port" {
  description = "kafka port"
  type        = number
}

variable "kafka_port" {
  description = "kafka port"
  type        = number
}
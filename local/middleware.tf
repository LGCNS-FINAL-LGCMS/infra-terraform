resource "null_resource" "middleware" {
  provisioner "local-exec" {
    command = "docker-compose -f docker/docker-compose.yaml -p lgcms up -d"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "docker-compose -f docker/docker-compose.yaml -p lgcms down"
  }
}
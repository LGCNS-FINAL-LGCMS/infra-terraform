resource "aws_elasticache_subnet_group" "main" {
  name = "${var.environment}-cache-subnet"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "${var.environment}-valkey"
  description = "Valkey cluster"

  node_type = var.cache_node_type
  port = 6379
  parameter_group_name = "default.valkey8"
  engine = "valkey"
  engine_version = "8.1"

  num_cache_clusters = 1

  subnet_group_name = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.elasticache.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = false

  tags = {
    Name = "${var.environment}-valkey"
  }
}

resource "null_resource" "init_nosql" {
  depends_on = [aws_instance.bastion, aws_elasticache_replication_group.main]

  provisioner "remote-exec" {
    inline = [
      "mkdir /tmp/valkey",
    ]

    connection {
      type = "ssh"
      host = aws_eip.bastion.public_ip
      user = "ubuntu"
      private_key = file(var.bastion_keypair_path)
    }
  }

  provisioner "file" {
    source      = "../../database/init-valkey/"
    destination = "/tmp/valkey/"

    connection {
      type = "ssh"
      host = aws_eip.bastion.public_ip
      user = "ubuntu"
      private_key = file(var.bastion_keypair_path)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y redis-tools",
      "for redis_file in $(find /tmp/valkey -name '*.redis' | sort -V); do echo \"Executing $redis_file...\"; redis-cli -h ${aws_elasticache_replication_group.main.primary_endpoint_address} -p ${aws_elasticache_replication_group.main.port} -n 15 < \"$redis_file\"; done",
    ]

    connection {
      type = "ssh"
      host = aws_eip.bastion.public_ip
      user = "ubuntu"
      private_key = file(var.bastion_keypair_path)
    }
  }
}


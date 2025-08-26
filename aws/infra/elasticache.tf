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
  transit_encryption_enabled = true

  tags = {
    Name = "${var.environment}-valkey"
  }
}

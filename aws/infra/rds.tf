resource "aws_db_subnet_group" "main" {
  name = "${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier = "${var.environment}-postgres-db"

  engine = "postgres"
  engine_version = "17.5"
  instance_class = var.rds_instance_class

  allocated_storage = var.rds_allocated_storage
  max_allocated_storage = var.rds_allocated_storage
  storage_type = "gp3"
  storage_encrypted = true

  db_name = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = 0

  skip_final_snapshot = true
  deletion_protection = false

  performance_insights_enabled = false

  tags = {
    Name = "${var.environment}-postgres-db"
  }
}

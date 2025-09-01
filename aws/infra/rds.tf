resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier = "${var.environment}-postgres-db"

  engine         = "postgres"
  engine_version = "17.5"
  instance_class = var.rds_instance_class

  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
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

resource "null_resource" "init_rds_schema" {
  depends_on = [aws_instance.bastion, aws_db_instance.main]

  provisioner "remote-exec" {
    inline = [
      "mkdir /tmp/sql",
    ]

    connection {
      type = "ssh"
      host = aws_eip.bastion.public_ip
      user = "ubuntu"
      private_key = file(var.bastion_keypair_path)
    }
  }

  provisioner "file" {
    source      = "../../database/init-sql/common/01-init.sql"
    destination = "/tmp/sql/01-init.sql"

    connection {
      type = "ssh"
      host = aws_eip.bastion.public_ip
      user = "ubuntu"
      private_key = file(var.bastion_keypair_path)
    }
  }

  provisioner "file" {
    source      = "../../database/init-sql/database/auth/"
    destination = "/tmp/sql/"

    connection {
      type = "ssh"
      host = aws_eip.bastion.public_ip
      user = "ubuntu"
      private_key = file(var.bastion_keypair_path)
    }
  }

  provisioner "file" {
    source      = "../../database/init-sql/database/consulting/"
    destination = "/tmp/sql/"

    connection {
      type = "ssh"
      host = aws_eip.bastion.public_ip
      user = "ubuntu"
      private_key = file(var.bastion_keypair_path)
    }
  }

  provisioner "file" {
    source      = "../../database/init-sql/database/core/"
    destination = "/tmp/sql/"

    connection {
      type = "ssh"
      host = aws_eip.bastion.public_ip
      user = "ubuntu"
      private_key = file(var.bastion_keypair_path)
    }
  }

  provisioner "file" {
    source      = "../../database/init-sql/database/guide/"
    destination = "/tmp/sql/"

    connection {
      type = "ssh"
      host = aws_eip.bastion.public_ip
      user = "ubuntu"
      private_key = file(var.bastion_keypair_path)
    }
  }

  provisioner "file" {
    source      = "../../database/init-sql/database/lecture/"
    destination = "/tmp/sql/"

    connection {
      type = "ssh"
      host = aws_eip.bastion.public_ip
      user = "ubuntu"
      private_key = file(var.bastion_keypair_path)
    }
  }

  provisioner "file" {
    source      = "../../database/init-sql/database/lesson/"
    destination = "/tmp/sql/"

    connection {
      type = "ssh"
      host = aws_eip.bastion.public_ip
      user = "ubuntu"
      private_key = file(var.bastion_keypair_path)
    }
  }

  provisioner "file" {
    source      = "../../database/init-sql/database/leveltest/"
    destination = "/tmp/sql/"

    connection {
      type = "ssh"
      host = aws_eip.bastion.public_ip
      user = "ubuntu"
      private_key = file(var.bastion_keypair_path)
    }
  }

  provisioner "file" {
    source      = "../../database/init-sql/database/member/"
    destination = "/tmp/sql/"

    connection {
      type = "ssh"
      host = aws_eip.bastion.public_ip
      user = "ubuntu"
      private_key = file(var.bastion_keypair_path)
    }
  }

  provisioner "file" {
    source      = "../../database/init-sql/database/notification/"
    destination = "/tmp/sql/"

    connection {
      type = "ssh"
      host = aws_eip.bastion.public_ip
      user = "ubuntu"
      private_key = file(var.bastion_keypair_path)
    }
  }

  provisioner "file" {
    source      = "../../database/init-sql/database/payment/"
    destination = "/tmp/sql/"

    connection {
      type = "ssh"
      host = aws_eip.bastion.public_ip
      user = "ubuntu"
      private_key = file(var.bastion_keypair_path)
    }
  }

  provisioner "file" {
    source      = "../../database/init-sql/database/tutor/"
    destination = "/tmp/sql/"

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
      "sudo apt-get install -y postgresql-client",
      "for sql_file in $(find /tmp/sql -name '*.sql' | sort -V); do echo \"Executing $sql_file...\"; PGPASSWORD=${var.db_password} psql -h ${aws_db_instance.main.address} -p ${aws_db_instance.main.port} -U ${var.db_username} -f \"$sql_file\"; done"
    ]

    connection {
      type = "ssh"
      host = aws_eip.bastion.public_ip
      user = "ubuntu"
      private_key = file(var.bastion_keypair_path)
    }
  }
}

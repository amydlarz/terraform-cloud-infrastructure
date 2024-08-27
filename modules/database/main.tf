locals {
  db_identifier = "db-instance"
}

resource "aws_db_instance" "db" {
  identifier              = local.db_identifier
  instance_class          = "db.t4g.micro"
  engine                  = "postgres"
  engine_version          = "16.3"
  username                = "postgres"
  password                = random_password.db_password.result
  db_name                 = "postgres"
  allocated_storage       = 10
  multi_az                = true
  backup_retention_period = 7
  storage_type            = "gp2"
  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot     = true

  tags = {
    Name = "db-instance"
  }
}

resource "aws_security_group" "db" {
  name        = "db-sg"
  description = "Allow inbound traffic to RDS instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = var.allow_traffic_from_sgs
  }

  tags = {
    Name = "db-sg"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "db-subnet-group"
  }
}

resource "random_password" "db_password" {
  length  = 16
  special = true
  keepers = {
    instance_id = local.db_identifier
  }
}

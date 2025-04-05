resource "aws_db_subnet_group" "medusa" {
  name       = "medusa-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "Medusa DB subnet group"
  }
}

resource "aws_db_instance" "medusa" {
  identifier             = "medusa-db"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "12.22"
  username               = var.db_username
  password               = var.db_password
  db_name                = "medusa"
  db_subnet_group_name   = aws_db_subnet_group.medusa.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  storage_encrypted      = true
}

resource "aws_security_group" "rds" {
  name        = "medusa-rds-sg"
  description = "Allow PostgreSQL traffic from ECS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

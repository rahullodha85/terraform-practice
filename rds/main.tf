resource "aws_db_parameter_group" "mariadb-parameters" {
  name = "mariadb-parameters"
  family = "mariadb10.3"
  description = "MariaDB parameter group"
  parameter {
    name = "max_allowed_packet"
    value = "16777216"
  }
}

resource "aws_db_subnet_group" "mariadb-subnet" {
  name = "mariadb-subnet"
  description = "RDS mariadb subnet group"
  subnet_ids = ["${var.MARIADB_SECURITY_GRP_ID_LIST}"]
}

resource "aws_db_instance" "mariadb" {
  allocated_storage = 100
  engine = "mariadb"
  engine_version = "10.3.8"
  instance_class = "db.t2.micro"
  identifier = "mariadb"
  name = "mariadb"
  username = "root"
  password = "${var.MARIADB_PASSWORD}"
  db_subnet_group_name = "${aws_db_subnet_group.mariadb-subnet.name}"
  parameter_group_name = "${aws_db_parameter_group.mariadb-parameters.name}"
  multi_az = "false"
  vpc_security_group_ids = ["${var.MARIADB_SECURITY_GRP_ID}"]
  storage_type = "gp2"
  backup_retention_period = 30
  availability_zone = "${var.PREFERRED_MARIADB_AVAILABILITY_ZONE}"
  skip_final_snapshot = true
  tags {
    Name = "mariadb-instance"
  }
}
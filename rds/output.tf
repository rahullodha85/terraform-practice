output "rds_host" {
  value = "${aws_db_instance.mariadb.address}"
}
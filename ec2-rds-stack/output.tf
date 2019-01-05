output "ec2_instance_public_ip" {
  value = "${module.ec2-instance.public_ip}"
}

output "mariadb_host_name" {
  value = "${module.rds}"
}
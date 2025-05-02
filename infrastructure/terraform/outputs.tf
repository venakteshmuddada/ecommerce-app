output "ec2_security_group_id" {
  value = aws_security_group.ec2_sg.id
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

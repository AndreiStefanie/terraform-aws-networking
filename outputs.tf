output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "public_sg" {
  value = aws_security_group.this["public"].id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.rds[*].name
}

output "db_security_group" {
  value = aws_security_group.this["rds"].id
}

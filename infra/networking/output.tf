output "private_subnet_ids" {
  description = "Private subnets id"
  value       = aws_subnet.private_subnet.*.id
}

output "vpc_id" {
  value = aws_vpc.this.id
}
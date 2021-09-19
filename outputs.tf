output "web1" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web1.id
}

output "web1_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web1.public_ip
}

output "web1_public_dns" {
  description = "Public A record of the EC2 instance"
  value       = aws_instance.web1.public_dns
}
output "web2" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web2.id
}

output "web2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web2.public_ip
}

output "web2_public_dns" {
  description = "Public A record of the EC2 instance"
  value       = aws_instance.web2.public_dns
}
output "lb_dns_name" {
  description = "Public A record of the alb"
  value       = module.alb.lb_dns_name
}

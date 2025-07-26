output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.fleet_smart.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.fleet_smart_eip.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.fleet_smart.public_dns
}

output "odoo_url" {
  description = "URL to access Odoo Fleet Smart application"
  value       = "http://${aws_eip.fleet_smart_eip.public_ip}:8069"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/fleet-smart-key ubuntu@${aws_eip.fleet_smart_eip.public_ip}"
}
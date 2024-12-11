output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnets_ids
}

output "private_subnets_ids" {
  description = "The IDs of the private subnets"
  value       = module.vpc.private_subnets_ids
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = module.vpc.private_route_table_id
}

output "security_group_id" {
  value = module.web_server_sg.security_group_id
}

# EC2 instances
# Output para instance_ollama
output "instance_ollama_id" {
  description = "ID de la instancia EC2 para instance ollama"
  value       = module.instance_ollama.instance_id
}

output "instance_ollama_public_ip" {
  description = "Dirección IP pública de la instancia EC2 para instance ollama"
  value       = module.instance_ollama.public_ip
}

# Output para instance_openwebui
output "instance_openwebui_id" {
  description = "ID de la instancia EC2 para instance openwebui"
  value       = module.instance_openwebui.instance_id
}

output "instance_openwebui_public_ip" {
  description = "Dirección IP pública de la instancia EC2 para instance openwebui"
  value       = module.instance_openwebui.public_ip
}

# load_balancer
output "tg_id" {
  value = module.load_balancer.tg.id
}

output "elb_id" {
  value = module.load_balancer.elb.id
}

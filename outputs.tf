//  VPC OUTPUTS

output "vpc_id" {
  description = "ID of the VPC"
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

//  EKS OUTPUTS

output "eks_cluster_endpoint" {
  description = "Endpoint for cluster"
  value = module.eks.cluster_endpoint
}

//  RDS OUTPUTS

output "rds_endpoint" {
  description = "Endpoint rds db"
  value = module.rds.db_instance_endpoint
}

output "rds_port" {
  description = "Port for the RDS instance"
  value       = module.rds.db_instance_port
}
output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Public endpoint for the EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "ID of the VPC created for EKS."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by the cluster and node group."
  value       = module.vpc.public_subnets
}

output "kubectl_configure_command" {
  description = "Command to write kubeconfig for the new EKS cluster."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

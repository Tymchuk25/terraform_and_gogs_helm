output "eks_admin_role_arn" {
   description = "ARN of the EKS admin IAM role."
   value = aws_iam_role.eks_admin.arn
}

output "eks_admin_policy_arn" {
  description = "ARN of the EKS admin IAM policy."
  value       = aws_iam_policy.eks_admin_custom.arn
}
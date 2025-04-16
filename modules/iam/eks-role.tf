resource "aws_iam_role" "eks_admin" {
  name = "eks-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::719319039943:root"
        },
        Action = "sts:AssumeRole",
        Condition = {
          StringEquals = {
            "aws:username" = "eks-admin"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eks_admin_custom" {
  name = "eks-admin-custom-policy"
  description = "Least-privilege policy for EKS cluster administration"

  policy = jsonencode(
    {
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "eks:*",
          "ec2:Describe*",
          "iam:ListRoles",
          "iam:PassRole",
          "logs:*"
        ],
        Resource = "*"
      }
    ]
  }
  )
}

resource "aws_iam_role_policy_attachment" "eks_admin_attach" {
  role       = aws_iam_role.eks_admin.name
  policy_arn = aws_iam_policy.eks_admin_custom.arn
}
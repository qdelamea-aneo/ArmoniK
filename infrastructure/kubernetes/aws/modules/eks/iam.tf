# Agent permissions
data "aws_iam_policy_document" "worker_assume_role_agent_permissions_document" {
  statement {
    sid       = ""
    effect    = "Allow"
    actions   = [
      "sqs:*",
      "dynamodb:*",
      "lambda:*",
      "logs:*",
      "s3:*",
      "mq:*",
      "elasticache:*",
      "firehose:*",
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "route53:AssociateVPCWithHostedZone"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "worker_assume_role_agent_permissions_policy" {
  name_prefix = "eks-worker-assume-agent-${module.eks.cluster_id}"
  description = "EKS worker node policy for agent in  cluster ${module.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.worker_assume_role_agent_permissions_document.json
}

resource "aws_iam_role_policy_attachment" "worker_assume_role_agent_permissions_document" {
  policy_arn = aws_iam_policy.worker_assume_role_agent_permissions_policy.arn
  role       = module.eks.worker_iam_role_name
}

# SSM managed instance core
resource "aws_iam_role_policy_attachment" "ssm_agent" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = module.eks.worker_iam_role_name
}

# X-ray
resource "aws_iam_role_policy_attachment" "workers_xray_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = module.eks.worker_iam_role_name
}

# Decrypt objects in S3
data "aws_iam_policy_document" "decrypt_object_document" {
  statement {
    sid       = "KMSAccess"
    actions   = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    effect    = "Allow"
    resources = [
      var.eks.encryption_keys.ebs_kms_key_id,
      var.eks.encryption_keys.cluster_log_kms_key_id,
      var.eks.encryption_keys.cluster_encryption_config,
    ]
  }
}

resource "aws_iam_policy" "decrypt_object_policy" {
  name_prefix = "decrypt-${module.eks.cluster_id}"
  description = "Policy for alowing decryption of encrypted object in S3 ${module.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.decrypt_object_document.json
}

resource "aws_iam_role_policy_attachment" "decrypt_object_attachment" {
  policy_arn = aws_iam_policy.decrypt_object_policy.arn
  role       = module.eks.worker_iam_role_name
}

locals {
  name_prefix = substr("${var.cluster_name}-external-dns", 0, 32)
}

data "aws_iam_policy_document" "aws_external-dns" {
  statement {
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets"
    ]

    resources = [for h in var.hosted_zone_ids : "arn:aws:route53:::hostedzone/${h}"]
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "aws_external-dns" {
  name        = "local.name_prefix-${var.prefix}"
  description = "External DNS policy for EKS cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.aws_external-dns.json
}

module "irsa_aws_external-dns" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.2"
  
  create_role                   = true
  role_name                     = "local.name_prefix-${var.prefix}"
  provider_url                  = var.cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.aws_external-dns.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"]
  tags                          = var.tags
}

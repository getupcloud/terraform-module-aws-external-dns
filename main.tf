locals {
  name_prefix = substr("${var.cluster_name}-external-dns", 0, 32)
}

data "aws_iam_policy_document" "aws_external_dns" {
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

  dynamic "statement" {
    for_each = length(var.hosted_zone_ids) > 0 ? ["hosted_zone_ids"] : []
    content {
      effect = "Allow"

      actions = [
        "route53:ChangeResourceRecordSets"
      ]

      resources = [for id in var.hosted_zone_ids : "arn:aws:route53:::hostedzone/${id}"]
    }
  }

  dynamic "statement" {
    for_each = length(var.hosted_zone_ids) > 0 ? [] : ["all_hosted_zone_ids"]
    content {
      effect = "Allow"

      actions = [
        "route53:ChangeResourceRecordSets"
      ]

      resources = ["arn:aws:route53:::hostedzone/*"]
    }
  }
}

resource "aws_iam_policy" "aws_external_dns" {
  name        = "${local.name_prefix}-${var.prefix}"
  description = "External DNS policy for EKS cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.aws_external_dns.json
}

module "irsa_aws_external_dns" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.2"

  create_role                   = true
  role_name                     = "${local.name_prefix}-${var.prefix}"
  provider_url                  = var.cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.aws_external_dns.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"]
  tags                          = var.tags
}

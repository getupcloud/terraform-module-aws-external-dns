variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "customer_name" {
  description = "customer name"
  type        = string
}

variable "hosted_zone_ids" {
  description = "AWS Route53 Hosted Zone ID to external dns automatically handle"
  type        = list(string)
  default     = []
}

variable "cluster_oidc_issuer_url" {
  description = "URL of the OIDC Provider from the EKS cluster"
  type        = string
}

variable "service_account_namespace" {
  description = "Namespace of ServiceAccount for external-dns"
  default     = "external-dns"
}

variable "service_account_name" {
  description = "ServiceAccount name for external-dns"
  default     = "external-dns"
}

variable "tags" {
  description = "AWS tags to apply to resources"
  type        = any
  default     = {}
}

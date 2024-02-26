output "id" {
    description = <<-EOF
        description: EKS cluster의 ID정보를 제공합니다.
    EOF
    value = module.eks_cluster.cluster_id
}

output "name" {
    description = <<-EOF
        description: EKS cluster Name 정보를 제공합니다.
    EOF
    value = module.eks_cluster.cluster_name
}

output "arn" {
    description = <<-EOF
        description: EKS cluster arn 정보를 제공합니다.
    EOF
    value = module.eks_cluster.cluster_arn
}

output "ca" {
    description = <<-EOF
        description: Base64 encoded certificate data required to communicate with the cluster
    EOF
    value = module.eks_cluster.cluster_certificate_authority_data
}

output "endpoint" {
    description = <<-EOF
        description: EKS cluster endpoint address를 제공합니다.
    EOF
    value = module.eks_cluster.cluster_endpoint
}

output "oidc_arn" {
    description = <<-EOF
        description: EKS openid connect provider arn을 제공합니다. (IRSA에 사용합니다.)
    EOF
    value = module.eks_cluster.oidc_provider_arn
}

output "oidc_url" {
    description = <<-EOF
        description: EKS openid connect provider url를 제공합니다. (IRSA에 사용합니다.)
    EOF
    value = module.eks_cluster.cluster_oidc_issuer_url
}
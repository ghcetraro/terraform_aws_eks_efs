#
module "efs-csi-controller-sa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.17.0"
  #
  role_name             = "efs-csi-controller-sa"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true
  attach_ebs_csi_policy = true
  #
  oidc_providers = {
    ex = {
      provider_arn               = data.terraform_remote_state.eks.outputs.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
}
#
resource "aws_iam_policy" "efs_access_policy" {
  name        = "efs-access-policy-${var.region}"
  description = "Allow to read/use KMS keys"
  policy      = file("manifests/efs.json")
  tags        = local.tags
}
#
resource "aws_iam_role_policy_attachment" "efs_access_policy" {
  role       = module.efs-csi-controller-sa.iam_role_name
  policy_arn = aws_iam_policy.efs_access_policy.arn
  depends_on = [module.efs-csi-controller-sa]
}
#
resource "aws_eks_addon" "aws_efs_csi_driver" {
  cluster_name  = local.app_name_dashed
  addon_name    = "aws-efs-csi-driver"
  addon_version = "v2.0.4-eksbuild.1"
  #
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = module.efs-csi-controller-sa.iam_role_arn
  #
  configuration_values = jsonencode({
    controller = {
      tolerations : [
        {
          key : "system",
          operator : "Equal",
          value : "owned",
          effect : "NoSchedule"
        }
      ]
    }
  })
  #
  preserve = true
  #
  tags = {
    "eks_addon" = "aws-ebs-csi-driver"
  }
  depends_on = [module.efs-csi-controller-sa]
}
#
resource "aws_security_group" "efs" {
  name        = "${local.app_name_dashed} efs"
  description = "Allow traffic"
  vpc_id      = data.terraform_remote_state.stack.outputs.vpc_id
  #
  ingress {
    description = "nfs"
    from_port   = 2049
    to_port     = 2049
    protocol    = "TCP"
    cidr_blocks = ["${data.terraform_remote_state.stack.outputs.vpc_cidr_block}"]
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = merge({
    "Name"      = "eks-efs-csi-driver"
    "eks_addon" = "aws-efs-csi-driver"
    },
    local.tags,
  )
}
#
resource "aws_efs_file_system" "kube" {
  creation_token = "eks-efs"
  encrypted      = true
  tags = merge({
    "eks_addon" = "aws-efs-csi-driver"
    "Name"      = "eks-efs"
    },
    local.tags,
  )
}
#
resource "aws_efs_mount_target" "mount" {
  file_system_id  = aws_efs_file_system.kube.id
  subnet_id       = each.key
  for_each        = toset(var.subnets)
  security_groups = [aws_security_group.efs.id]
  depends_on = [
    aws_efs_file_system.kube,
    aws_security_group.efs,
  ]
}
#
resource "kubectl_manifest" "efs_storage_class" {
  yaml_body = <<-YAML
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: ${aws_efs_file_system.kube.id}
  directoryPerms: "700"
  YAML
  #
  depends_on = [
    aws_efs_file_system.kube
  ]
}
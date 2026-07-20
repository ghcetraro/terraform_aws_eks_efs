# Uso y despliegue

## Descripción

Almacenamiento compartido en EKS: EFS + CSI driver + StorageClass — Terraform

Terraform que provisiona el driver EFS CSI en EKS (IRSA, manifests, StorageClass) listo para PVCs compartidos.

## Requisitos

- Terraform 1.x
- AWS CLI con permisos adecuados
- Para módulos EKS: cluster existente y acceso de API

## Variables

Usá siempre la plantilla **`terraform.tfvars.example`**. No subas `terraform.tfvars` ni el state.

### Módulo raíz del repo

```bash
# desde la raíz
cp terraform.tfvars.example terraform.tfvars
# Completar variables y locals según tu cuenta/cluster

aws sso login --profile <tu-profile>   # o credenciales equivalentes
terraform init
terraform plan
terraform apply
```


## Post-apply

Revisá outputs del módulo y recursos en la consola AWS / `kubectl` según corresponda.

## Seguridad

Ver [SECURITY.md](../SECURITY.md).

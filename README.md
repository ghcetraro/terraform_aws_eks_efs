# EFS CSI Driver para EKS

[![License: MIT](https://img.shields.io/github/license/ghcetraro/terraform_aws_eks_efs)](LICENSE)
[![Terraform](https://img.shields.io/badge/terraform-1.x-7B42BC.svg)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-compatible-FF9900.svg)](https://aws.amazon.com/)
[![CI](https://github.com/ghcetraro/terraform_aws_eks_efs/actions/workflows/ci.yml/badge.svg)](https://github.com/ghcetraro/terraform_aws_eks_efs/actions/workflows/ci.yml)

**Almacenamiento compartido en EKS: EFS + CSI driver + StorageClass — Terraform**

---

## El problema

Muchas apps en EKS necesitan volúmenes ReadWriteMany. EBS no alcanza; armar EFS + CSI a mano es repetitivo.

## La solución

Terraform que provisiona el driver EFS CSI en EKS (IRSA, manifests, StorageClass) listo para PVCs compartidos.

```mermaid
flowchart LR
  POD[Pods] --> PVC[PVC]
  PVC --> SC[StorageClass]
  SC --> CSI[EFS CSI]
  CSI --> EFS[(Amazon EFS)]
  TF[Terraform] --> CSI
```

---

## Características

| Área | Detalle |
|------|---------|
| **EFS CSI** | Driver en el cluster EKS |
| **IRSA** | Permisos IAM vía OIDC |
| **PVC** | Base para StorageClass RWX |
| **IaC** | Repetible entre ambientes |

---

## Limitaciones y disclaimer

- Pensado como **punto de partida / referencia**: revisá roles IAM, redes y secretos antes de producción.
- Requiere **credenciales AWS** (recomendado SSO) y, en módulos EKS, acceso al cluster (kubeconfig / exec).
- Completá `locals` y variables según tu cuenta; los ejemplos usan valores ficticios.
- Software open source “as is” — probá primero en un ambiente no productivo.

---

## Stack

Terraform · EKS · EFS · CSI Driver · IRSA

---

## Inicio rápido

### Requisitos

- Terraform CLI 1.x
- AWS CLI configurado (`aws sso login` o credenciales)
- Permisos de administración en la cuenta / cluster según el módulo

### Configuración

```bash
# En cada módulo: copiá la plantilla (no commitear terraform.tfvars)
cp terraform.tfvars.example terraform.tfvars
```

Valores de ejemplo: `terraform.tfvars.example`

### Apply

```bash
cp terraform.tfvars.example terraform.tfvars
# Editar valores (cuenta, región, cluster, etc.)

terraform init
terraform plan
terraform apply
```

---

## Documentación

- [Uso y despliegue](docs/uso.md)
- [Presentación / LinkedIn](docs/PRESENTACION.md)
- [Speech para LinkedIn](docs/speech-linkedin.md)
- [Changelog](CHANGELOG.md)
- [Contribuir](CONTRIBUTING.md)
- [Seguridad](SECURITY.md)

---

## Seguridad

**No commitees** `terraform.tfvars`, state, claves ni tokens. Usá `*.tfvars.example` como plantilla.

Ver [SECURITY.md](SECURITY.md).

---

## Licencia

[MIT](LICENSE) — Copyright (c) Gabriel Cetraro

---

## Autor

Proyecto open source de **Gabriel Cetraro** — automatización de infraestructura, AWS, Kubernetes y observabilidad.

Si te resulta útil, ⭐ en GitHub ayuda a darle visibilidad.

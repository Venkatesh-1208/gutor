# Azure Hub Network – Terraform

A production-ready, modular Terraform project that deploys an **Azure Hub network** in a single subscription.

## Architecture Overview

```
Hub Subscription
└── Hub VNet (10.0.0.0/16)
    ├── snet-management      (10.0.0.0/24)  ← Management
    ├── AzureFirewallSubnet  (10.0.1.0/24)  ← Azure Firewall (DMZ)
    ├── snet-private         (10.0.2.0/24)  ← Internal Load Balancer
    ├── snet-public          (10.0.3.0/24)  ← External Load Balancer
    ├── snet-appgateway      (10.0.4.0/24)  ← Application Gateway WAF v2
    ├── snet-natgateway      (10.0.5.0/24)  ← NAT Gateway
    ├── snet-corporate       (10.0.6.0/24)  ← Corporate access
    └── AzureBastionSubnet   (10.0.7.0/26)  ← Azure Bastion
```

## Resources Deployed

| Resource | Name |
|---|---|
| Azure Firewall (Standard/Premium) | fw-hub |
| Firewall Policy + Rules | fwpol-hub |
| Application Gateway WAF v2 | agw-hub |
| NAT Gateway | natgw-hub |
| Internal Standard LB | lb-internal-hub |
| External Standard LB | lb-external-hub |
| Azure Bastion | bas-hub |
| Route Tables (UDR → Firewall) | rt-hub |
| NSGs | nsg-management, nsg-private |

All resources are **optional** — control which ones deploy via feature flags in `.tfvars`.

## File Structure

```
hub-spoke-terraform/
├── main.tf                        # Root – wires hub module + provider
├── variables.tf                   # All input variables
├── outputs.tf                     # Key resource IDs/IPs
├── terraform.tfvars               # Base/default values
├── environments/
│   ├── test/test.tfvars           # Test environment overrides
│   └── prod/prod.tfvars           # Production environment overrides
└── modules/
    └── hub/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Quick Start

### 1. Prerequisites

- Terraform >= 1.5.0
- Azure CLI authenticated (`az login`)
- Owner/Contributor role on the Hub subscription

### 2. Configure

Edit `terraform.tfvars` – at minimum set your real subscription ID:

```hcl
hub_subscription_id = "<your-hub-sub-id>"
```

### 3. Deploy

```bash
# Base values
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Test environment
terraform plan -var-file="environments/test/test.tfvars" -out=tfplan
terraform apply tfplan

# Production environment
terraform plan -var-file="environments/prod/prod.tfvars" -out=tfplan
terraform apply tfplan
```

### 4. Feature Flags

Control which resources are deployed via boolean flags in `.tfvars`:

```hcl
deploy_firewall    = true
deploy_appgw       = true
deploy_nat_gateway = true
deploy_bastion     = true
deploy_internal_lb = true
deploy_external_lb = true
```

Set any flag to `false` to skip that resource (useful for cost optimization in non-prod).

### 5. Destroy

```bash
terraform destroy
```

## Security Notes

> ⚠️ **Production recommendations:**
> - Store Terraform state in **Azure Blob Storage** (uncomment the `backend` block in `main.tf`)
> - Enable **Azure Defender for Cloud** on the subscription
> - Tighten NSG rules to match actual workload requirements

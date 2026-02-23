# Hub-Spoke Azure Network Topology – Terraform

A production-ready, modular Terraform project that deploys an **Azure Hub-Spoke network architecture** across multiple subscriptions.

## Architecture Overview

```
Hub Subscription
└── Hub VNet (10.0.0.0/16)
    ├── snet-management      (10.0.0.0/24)  ← Azure Bastion
    ├── AzureFirewallSubnet  (10.0.1.0/24)  ← Azure Firewall (DMZ)
    ├── snet-private         (10.0.2.0/24)  ← Internal Load Balancer
    ├── snet-public          (10.0.3.0/24)  ← External Load Balancer
    ├── snet-appgateway      (10.0.4.0/24)  ← Application Gateway WAF v2
    ├── snet-natgateway      (10.0.5.0/24)  ← NAT Gateway
    ├── snet-corporate       (10.0.6.0/24)  ← Corporate access
    └── AzureBastionSubnet   (10.0.7.0/26)  ← Bastion Host

Spoke Subscription #1
└── vnet-spoke1 (10.1.0.0/16)
    └── snet-workload-spoke1 (10.1.0.0/24) ← Linux VMs + NSG

Spoke Subscription N
└── vnet-spoke-n (10.2.0.0/16)
    └── snet-workload-spoke-n (10.2.0.0/24) ← Linux VMs + NSG

Peerings: Hub ↔ Spoke1, Hub ↔ SpokeN (bidirectional)
```

## Resources Deployed

### Hub
| Resource | Name |
|---|---|
| Azure Firewall (Standard) | fw-hub |
| Firewall Policy + Rules | fwpol-hub |
| Application Gateway WAF v2 | agw-hub |
| NAT Gateway | natgw-hub |
| Internal Standard LB | lb-internal-hub |
| External Standard LB | lb-external-hub |
| Azure Bastion | bas-hub |
| Route Tables (UDR → Firewall) | rt-hub |
| NSGs | nsg-management, nsg-private |

### Spokes (each)
| Resource | Details |
|---|---|
| VNet + Subnet | Configurable CIDR |
| NSG | Allow VNet + deny internet |
| UDR | Route 0.0.0.0/0 via Hub Firewall |
| Linux VMs | Ubuntu 22.04, Standard_D2s_v3 |
| Availability Set | 2 fault / 5 update domains |

## File Structure

```
hub-spoke-terraform/
├── main.tf               # Root – wires modules + providers
├── variables.tf          # All input variables
├── outputs.tf            # Key resource IDs/IPs
├── terraform.tfvars      # ← Edit with your values
└── modules/
    ├── hub/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── spoke/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── peering/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── providers.tf
```

## Quick Start

### 1. Prerequisites
- Terraform >= 1.5.0
- Azure CLI authenticated (`az login`)
- Owner/Contributor role on all three subscriptions

### 2. Configure

Edit `terraform.tfvars` – at minimum set real subscription IDs and a secure password:

```hcl
hub_subscription_id     = "<your-hub-sub-id>"
spoke1_subscription_id  = "<your-spoke1-sub-id>"
spoke_n_subscription_id = "<your-spoken-sub-id>"
admin_password          = "<SecurePassword123!>"
```

### 3. Deploy

```bash
cd hub-spoke-terraform

terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 4. Destroy

```bash
terraform destroy
```

## Security Notes

> ⚠️ **Production recommendations:**
> - Store `admin_password` in **Azure Key Vault** and reference via `data.azurerm_key_vault_secret`
> - Enable **Azure Defender for Cloud** on all subscriptions
> - Use **SSH keys** instead of passwords for Linux VMs
> - Store Terraform state in **Azure Blob Storage** (uncomment the `backend` block in `main.tf`)
> - Tighten NSG rules to match actual workload requirements

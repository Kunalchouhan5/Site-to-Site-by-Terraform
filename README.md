# site-to-site-by-terraform

This project demonstrates the implementation of a **Site-to-Site VPN connection** between an **on-premises network** and an **Azure Virtual Network (VNet)** using **Terraform**.  
It establishes a **secure, encrypted communication channel** for hybrid cloud environments.

---

## Table of Contents
- Overview
- Key Components
- Workflow
- Security
- Outputs
- Tools Used

---

##  Overview

This setup connects:
- **Azure Virtual Network (VNet)** on the cloud  
- **On-Premises Network** (simulated or physical)  
through a **Site-to-Site IPsec/IKE VPN tunnel** using Terraform automation.

---

## Key Components

- **Azure Virtual Network (VNet):** Hosts Azure resources.

- **VPN Gateway:** Handles VPN traffic and routing.

- **Local Network Gateway:** Represents on-premises configuration (public IP & address space).

- **VPN Connection:** Establishes the IPsec/IKE tunnel between gateways.

- **Terraform Files:**

**main.tf** → Core infrastructure setup

**variables.tf** → Variable declarations

**providers.tf** → Azure provider configuration

## Workflow

### Initialize Terraform
terraform init
### Review the deployment plan
terraform plan
### Apply configuration to create resources
terraform apply

## Security

- Encrypted tunnel using IPsec/IKE
- Shared key authentication
- Controlled access via Network Security Groups (NSGs)

## Outputs

- VPN Gateway Public IP
- Local Network Gateway IP
- Connection Status

## Tool Used

- Terraform
- Azure Infra
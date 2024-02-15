# HashiTalks 2024 - Terraforming AKS: Best Practices and Design Considerations
This repository contains Terraform code that provisions a fully configured Azure Kubernetes Service (AKS) cluster, meticulously crafted to adhere to the best practices and design considerations discussed at HashiTalks 2024. It showcases an advanced, secure, and resilient AKS deployment strategy that incorporates the following key features:

1. Entra Identity and Access Management: Integration with Azure Entra (formerly known as Azure Active Directory) for robust authentication and authorization, ensuring secure access control to the AKS cluster.
2. Private Networking: Deployment within a virtual network, utilizing Private Endpoint Connections to securely connect to other Azure services without exposing data to the public internet, enhancing network security and reducing the attack surface.
3. Azure KeyVault Integration: Secure storage and management of secrets, keys, and certificates used by AKS through Azure KeyVault, enabling automated, secure access to these sensitive resources from within the cluster.
4. Azure Monitor Integration: Comprehensive monitoring and logging setup with Azure Monitor, providing deep insights into the cluster's performance, health, and operational activities. This ensures proactive management and troubleshooting capabilities.
5. AZ Resiliency Configuration: High availability setup across multiple Availability Zones (AZs) to ensure the cluster remains operational even in the event of an AZ failure. This includes a preview of Azure policy assignments to automatically apply best practices and compliance standards for resiliency.
6. Maintenance Plans: Implementation of a strategic maintenance plan for the AKS cluster, ensuring minimal downtime and disruption during upgrades, patching, and other maintenance activities.

The Terraform code in this repository is designed to be modular, reusable, and easy to customize, allowing for the rapid deployment of an AKS cluster that meets the complex requirements of modern applications while adhering to the highest standards of security, compliance, and operational efficiency.

## VPN Setup

Make sure to add the Private IP address of the DNS resolver to your VPN Gateway configuration.

```
<clientconfig>
    <dnsservers>
        <dnsserver>10.0.0.36</dnsserver>
    </dnsservers>
</clientconfig>
  ```

Connect to your AKS cluster!

```
az aks get-credentials --name aks-aztflab-dev-agyhy3jv --resource-group rg-aztflab-dev-agyhy3jv
```

## Azure Policy

https://github.com/Azure/azure-policy/blob/master/built-in-policies/policySetDefinitions/Resilience/Resources_ZoneResilient.json
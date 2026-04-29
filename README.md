# AWS Network Hub
A Network Hub is a small AWS account designed that connects SaaS hosted on amazon (e.g. Salesforce, Databricks) via private gateways and under a governed security model. While a VPC in an existing account lacks inherent guardrails, this purpose build landing zone ensures that the network environment is pre-configured for compliance, centralized logging, and identity management before external services are connected. This transit zone serves as the administrative and technical boundary where the AWS network meets the service provider endpoint. 

## Technical Components

| Component | Technical Role | Necessity for Private IP |
| :--- | :--- | :--- |
| **VPC / VNet** | Logical isolation of resources. | Provides the private IP space for the connection. |
| **Interface Endpoint** | The physical/logical termination point. | Bridges the provider backbone to the SaaS account. |
| **Private DNS** | Authoritative internal name resolution. | Maps provider URLs to internal, private IPs. |
| **IAM & Guardrails** | Identity and Access Management. | Restricts who can modify the private connection. |

## Private Connectivity
The network zone enables cloud service integrations via private IP addressing, hence traffic does not traverse the public internet via standard HTTPS/TLS over an Internet Gateway, it utilizes *unroutable private IP addresses*. The setup provides the following functionality:

### Network Address Translation (NAT) and Routing
Often, SaaS clients in regulated industries like banking, insurance and healthcare require a *VPC Endpoint Interface* within a private subnet. This interface acts as the termination point. The network hub provides a VPC structure, with no logical location to assign the private IP addresses required for the two networks to "see" each other.

### Encapsulation of the Security Perimeter
A termination point allows for the application of Micro-segmentation. By terminating the connection in a controlled zone, organizations can apply *Stateful Firewalls* (Security Groups) and *Stateless Filters* (Network ACLs) directly to the endpoint. This ensures that if a resource within the cloud environment is compromised, the threat cannot move laterally into the Salesforce environment, as the landing zone acts as a strictly governed gateway.

### Resolution of Private DNS Namespaces
Public instances of services like Salesforce resolve to public IP addresses. When moving to a private connection, the system must resolve to a private IP within the VPC. The transit network provides the *Private DNS Zone* infrastructure. This infrastructure intercepts requests for the SaaS provider and redirects them to the private termination point, ensuring that data remains on the internal backbone.

### Auditability and Traffic Symmetrics
Regulatory frameworks (such as SOC2, HIPAA, or GDPR) often require proof of data transit paths. A network hub provides a centralized point for *VPC Flow Logs*. This captures every packet entering or leaving the Salesforce connection. Without this formal termination point, traffic monitoring becomes fragmented, making it difficult to verify that data has remained off the public internet during a compliance audit.

In summary, the transit network is the prerequisite infrastructure that transforms a "cloud account" into a "secure node" capable of supporting private, non-internet-routable peering with the SaaS provider.

# Connector Deployment

**1.) Create a VPC and it’s networking (see “VPC Creation / Deployment Basics”)**
[VPC Creation / Deployment Basics](/AWS/VPC_Creation_Deployment_Basics.md#vpc-creation-deployment-basics)

**2.) Setup a NetApp Cloud Central account**

- Sign up for Cloud Central acct - cloud.netapp.com
- ‘go to Cloud Manager’
- From CM - ADD connector

AWS Marketplace

- Requires subscription to Cloud Manager

**3.) AWS environment prep:**

IAM policy/roles:

- Download Connector IAM policy: https://s3.amazonaws.com/occm-sample-policies/Policy_for_Setup_As_Service.json
- Create a Policy for Cloud Manager: AWS -> IAM -> Policies -> Create -> JSON -> copy/past from the above link and replace ALL text in the JSON section (review, then save)

- Assign the policy to the IAM user that will be used to deploy the Connector: AWS -> IAM -> Uers -> Select User -> Permissions -> Add Permissions -> Attach Existing Policies Directly (this can be done via a ‘role’ as well)
- Create policy and Role for CVO instances as well
- Policies for BOTH Cloud Manager Connectors and CVO are found here: https://mysupport.netapp.com/site/info/cloud-manager-policies

**NOTE**: If your organization has SCP (Service Control Policies) that block any of the functionality listed in the JSON file then authentication via cloudmanager.netapp.com will fail.

S3 Endpoint for Tiering:

- If using Tiering MAKE sure you add the S3 endpoint: AWS -> VPC -> Endpoints -> Create Endpoint -> search for ’s3’ -> Choose the VPC for it -> add subnet associations -> Select a Security Group -> Create Endpoint
- Confirm that the S3 service is now in the Route Table associated with your Subnet
- Confirm that your route table has a route to the internet (0.0.0.0/0 with target of the Internet Gateway)

Authentication / Authorization:

- Get the IAM users Access Key and Secret Key ready: AWS -> IAM -> Users -> Select User -> Security Credentials (you only see the secret key at creation so if the user doesn’t have this info it must be created)
- Get the EC2 keypair for the region you want to deploy the connector in: AWS -> EC2 (make sure you’re in the correct AWS region in the dashboard) -> Key pairs
- Ensure a CMK - Customer Master Key exists: “Key Management Service” (for AWS managed encryption)

Networking / Firewall Rules

- If creating your own SG’s is desired create them now.
- SG for CVO in AWS: https://docs.netapp.com/us-en/occm/reference_security_groups.html#inbound-rules
- SG for Connector in all hyperscalers: https://docs.netapp.com/us-en/occm/reference_networking_cloud_manager.html#connection-to-target-networks

Transit Gateway:

- If deploying CVO as an HA pair across Availability Zones, a Transit Gateway is needed to allow access to the floating IPs (b/c the floating IP’s are outside of your VPCs entire CIDR block)
- See “Transit Gateway” Notes note for creation steps and considerations.

VPN Connectivity:

- If migrating data from On-premises ONTAP or accessing the VPC from outside of the environment a VPN (Client VPN Endpoint for single users or Site-to-Site VPN for connecting an entire on-premises subnet or range) or Direct Connect connection may be required.
- See [“AWS Client VPN Endpoint”](/AWS/Client_VPN_Endpoint.md#client-vpn-endpoint) or ["Site-to-Site VPN"](/AWS/Site-to-Site_VPN.md#site-to-site-vpn) for creation steps and considerations.

**4.) Add Connector: (learn about Connectors: https://docs.netapp.com/us-en/occm/concept_connectors.html)**

NOTE: Disable “Automatic Cloud Volumes ONTAP update during deployment” - this will significantly increase the deployment time (double or more)

- Requires AWS Account Admin privs
- Cloud Manager -> Add Working Environment
- Name the connector (ex. 'Region-CM')
- Ensure the connector goes into the subnet that you actually want it in.  NOTE the subnet for later use.

NOTE: If using a private IP for the connector then you’ll need a NAT gateway to talk to the required endpoints
NOTE: If using a private IP, you can load CM by typing the private IP into your browser once you’re VPN’d in.

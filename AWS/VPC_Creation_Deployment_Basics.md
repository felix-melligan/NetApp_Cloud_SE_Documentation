# VPC Creation / Deployment Basics

**1.) Create VPC**

- Name it
- Assign a CIDR block for networking

**2.) Create Subnets in each AZ desired**

- Needed in any AZ where you want connectivity
- Give them subnet CIDR blocks that are SUBSECTIONS of the VPCs CIDR block

**3.) Create an Internet Gateway**

- This gives the VPC access to resources OUTSIDE of it’s private subnet
- ATTACH it to the VPC (otherwise it’s not functional)

**4.) Add a route to the internet gateway**

- If outbound internet access is desired (critical for CVO deployments) then a route to the Internet Gateway in the default route table or whatever route table is being used for CVO MUST be added

- VPC -> Route Tables -> Choose desired route table -> Routes -> Edit Routes -> Add 0.0.0.0/0 with a ‘target’ of the Internet Gateway of the VPC

**5.) An admin user will exist at sign up for AWS (OPTIONAL: create user specifically for CM / CVO)**

- Make sure you have the ‘access keys’ for this user
- The secret key is only visible at creation and cannot be seen afterwards so must be kept in a secure place
- Once the Users keys are used to create a CVO connector, the user can be disabled - Cloud Manager will now have a role that allows it to deploy resources in the VPC.   This again is a strategy choice and is up to the customer / user.

**6.) Create EC2 keypairs**

- This is how ec2 instances are accessed
- In EC2 section under ‘keypairs’
- Store these in a secure location as .pem files
- keypairs can be created with different ‘strategies’ in mind (ex.  one for NetApp CVO, one for other types of deployments, etc.) or a single keypair can be used for all EC2 instances in that region.  This is a strategy choice for each customer / user.

**7.) Add S3 Endpoint (critical for CVO deployments)**

- Allows the VPC to talk to the S3 service
- VPC -> Endpoints -> Create Endpoint -> Search ’S3'
- ADD the Endpoint to a route table (the default is fine)
- VPC -> Endpoints -> Choose endpoint -> Route Tables -> Manage Route Tables

**8.) Create a Customer Master Key (also critical for CVO deployments)**

- Key Management Service -> Customer managed keys
- This key does not get downloaded.  It’s used within AWS only and is managed by AWS
- Grant a User and/or role to admin and use the key

**9.) Create Client VPN Endpoint**

- Follow steps in the “AWS Client VPN Endpoint” note
- For accessing resources within the VPC from outside of the VPC (like SSH into an instance or accessing NetApp System Manager)
- Alternatively, you can use a ‘jump host’ within the VPC that’s configured with a public IP address

**10.) Create a Transit Gateway (If deploying a Highly Available pair (HA) across multiple availability zones (AZ's))**

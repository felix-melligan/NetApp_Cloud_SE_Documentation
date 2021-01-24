# Pre-Requisites

These are the pre-requisites for deploying NetApp Cloud Manager with steps included (and labeled) that will also ensure the ability to deploy other NetApp services within your AWS VPC.

**1.)** You need to have a VPC deployed within the AWS infrastructure.  This is where NetApp services will run and should exist prior to any of the subsequent steps in these documents.  See [VPC Creation Deployment Basics](/AWS/VPC_Creation_Deployment_Basics.md#vpc-creation-deployment-basics)

**2.)** Required permissions to deploy a "Connector" (see [Connector Deployment](/AWS/Connector_Deployment.md#connector-deployment) for full instructions on deploying the Connector.

- You'll need an AWS user account with the ability to create and assign policies to roles.
- You'll need permission to subscribe and unsubscribe within the AWS Marketplace.
- The required permissions can be seen here: https://mysupport.netapp.com/site/info/cloud-manager-policies

**3.)** You'll need to have a NetApp Cloud Central account (https://cloud.netapp.com) - choose "sign up" if you do not already have an account.

**NOTE**: This should be an account with credentials you wish to administer NetApp Cloud products from.  For this reason it may be desirable to use a business email address that is already used for administering other resources rather than a personal email address.

**4.)** If you intend to migrate data into the hyperscaler environment then you need to be able to set up network communication on both ends.

- This could mean the ability to create or manage VPN tunnels or AWS Direct Connect connections.
- You need to be able to manage and deploy a Transit Gateway if you wish to deploy Cloud Volumes ONTAP as a Highly Available (HA) pair across multiple availability zones (AZ's) AND want to access the CVO instances from outside of the VPC.

**5.)** If you intend to use Tiering or Cloud Backup Service then you need to create an Endpoint for the S3 service for the VPC that will host the NetApp solutions.  This is outlined in [Connector Deployment](/AWS/Connector_Deployment.md#connector-deployment)

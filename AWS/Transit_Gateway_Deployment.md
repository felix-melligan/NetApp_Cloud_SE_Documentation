# Transit Gateway Requirements and Deployment

When deploying NetApp Cloud Volumes ONTAP as a Highly Available (HA) pair across multiple Availability Zones (AZ's), a Transit Gateway is required for clients OUTSIDE of the VPC to access the necessary Floating IP's (See "Floating IP Addresses" for more information).  This is NOT a requirement for clients INSIDE the VPC to access the Floating IP's.

**To Deploy an AWS Transit Gateway**:

1.) 

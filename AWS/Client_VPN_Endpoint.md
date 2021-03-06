# Client VPN Endpoint Creation

**COST CONCERN:** To DISABLE the VPN endpoint and stop incurring charges you can ‘disassociate’ the vpn endpoint from ALL subnets.  It will then show as ‘pending association’ and should no longer incur charges.

https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-getting-started.html#cvpn-getting-started-certs
https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-getting-started.html#cvpn-getting-started-endpoint

Setup AWS Client VPN & Access Private AWS Resources Across VPCs <- Video walk through of the above link

**Steps**:
* [Prerequisites](#Prerequisites)
* [Step 1: Generate server and client certificates and keys](#step-1-generate-server-and-client-certificates-and-keys)
* [Step 2: Create a Client VPN endpoint](#step-2-create-a-client-vpn-endpoint)
* [Step 3: Enable VPN connectivity for clients](#step-3-enable-vpn-connectivity-for-clients)
* [Step 4: Authorize clients to access a network](#step-4-authorize-clients-to-access-network)
* [Step 5: (Optional) Enable access to additional networks](#step-5-optional-enable-access-to-additional-networks)
* [Step 6: Download the Client VPN endpoint configuration file](#step-6-download-the-client-vpn-endpoint-configuration-file)
* [Step 7: Connect to the Client VPN endpoint](#step-7-connect-to-the-client-vpn-endpoint)
* [TROUBLESHOOTING](#troubleshooting)

## **Prerequisites** <a name="Prerequisites"></a>
To complete this getting started tutorial, you need the following:

- The permissions required to work with Client VPN endpoints.
- A VPC with at least one subnet and an internet gateway. The route table that's associated with your subnet must have a route to the internet gateway.


## **Step 1: Generate server and client certificates and keys** <a name="step-1-generate-server-and-client-certificates-and-keys"></a>

—— Uses EasyRSA to create certificates ——

- This tutorial uses mutual authentication. With mutual authentication, Client VPN uses certificates to perform authentication between the client and the server.
- For detailed steps to generate the server and client certificates and keys, see Mutual authentication.


## **Step 2: Create a Client VPN endpoint** <a name="step-2-create-a-client-vpn-endpoint"></a>

When you create a Client VPN endpoint, you create the VPN construct to which clients can connect in order to establish a VPN connection.

To create a Client VPN endpoint

**1.)** Open the Amazon VPC console at https://console.aws.amazon.com/vpc/.<br>
**2.)** In the navigation pane, choose Client VPN Endpoints and then choose Create Client VPN Endpoint.<br>
**3.)** (Optional) Provide a name and description for the Client VPN endpoint.<br>
**4.)** For Client IPv4 CIDR, specify an IP address range, in CIDR notation, from which to assign client IP addresses. For example, 10.0.0.0/22.<br>

**NOTE -**
The IP address range cannot overlap with the target network or any of the routes that will be associated with the Client VPN endpoint. The client CIDR range must have a block size that is between /12 and /22 and not overlap with VPC CIDR or any other route in the route table. You cannot change the client CIDR after you create the Client VPN endpoint.

**5.)** For Server certificate ARN, specify the ARN for the TLS certificate to be used by the server. Clients use the server certificate to authenticate the Client VPN endpoint to which they are connecting.<br>

**NOTE -**
The server certificate must be provisioned in AWS Certificate Manager (ACM).

**6.)** Specify the authentication method to be used to authenticate clients when they establish a VPN connection. For this tutorial, choose Use mutual authentication, and then for Client certificate ARN, specify the ARN of the client certificate that you generated in Step 1.<br>
**7.)** For Do you want to log the details on client connections?, choose No.<br>
**8.)** Leave the rest of the default settings, and choose Create Client VPN Endpoint.<br>

For more information about the other options that you can specify when creating a Client VPN endpoint, see Create a Client VPN endpoint.

**NOTE -**
After you create the Client VPN endpoint, its state is pending-associate. Clients can only establish a VPN connection after you associate at least one target network.


## **Step 3: Enable VPN connectivity for clients** <a name="step-3-enable-vpn-connectivity-for-clients"></a>

To enable clients to establish a VPN session, you must associate a target network with the Client VPN endpoint. A target network is a subnet in a VPC.

**To associate a subnet with the Client VPN endpoint**

**1.)** Open the Amazon VPC console at https://console.aws.amazon.com/vpc/.<br>
**2.)** In the navigation pane, choose **Client VPN Endpoints**.<br>
**3.)** Select the Client VPN endpoint with which to associate the subnet and choose **Associations** then **Associate**.<br>
**4.)** For **VPC**, choose the VPC in which the subnet is located. If you specified a VPC when you created the Client VPN endpoint, it must be the same VPC.<br>
**5.)** For **Subnet to associate**, choose the subnet to associate with the Client VPN endpoint.<br>
**6.)** Choose **Associate**.<br>

**NOTE -**
If authorization rules allow it, one subnet association is enough for clients to access a VPC's entire network. You can associate additional subnets to provide high availability in case one of the Availability Zones goes down.
 
When you associate the first subnet with the Client VPN endpoint, the following happens:

- The state of the Client VPN endpoint changes to available. Clients can now establish a VPN connection, but they cannot access any resources in the VPC until you add the authorization rules.
- The local route of the VPC is automatically added to the Client VPN endpoint route table.
- The VPC's default security group is automatically applied for the subnet association.


## **Step 4: Authorize clients to access a network** <a name="step-4-authorize-clients-to-access-network"></a>

To authorize clients to access the VPC in which the associated subnet is located, <ins>you must create an authorization rule</ins>. The authorization rule specifies which clients have access to the VPC. In this tutorial, you grant access to all users.

**To add an authorization rule to the target network**

**1.)** Open the Amazon VPC console at https://console.aws.amazon.com/vpc/.<br>
**2.)** In the navigation pane, choose **Client VPN Endpoints**.<br>
**3.)** Select the Client VPN endpoint to which to add the authorization rule, choose **Authorization**, and then choose **Authorize Ingress**.<br>
**4.)** For **Destination network to enable**, enter CIDR of the network for which you want to allow access. For example, to allow access to the entire VPC, specify the IPv4 CIDR block of the VPC.<br>
**5.)** For **Grant access to**, choose **Allow access to all users**.<br>
**6.)** For **Description**, enter a brief description of the authorization rule.<br>
**7.)** Choose **Add authorization rule**.<br>
**8.)** Ensure that the security groups for the resources in your VPC have a rule that allows access from the security group for the subnet association. This enables your clients to access the resources in your VPC. For more information, see Security groups.<br>
 

## **Step 5: (Optional) Enable access to additional networks** <a name="step-5-optional-enable-access-to-additional-networks"></a>

You can enable access to additional networks connected to the VPC, such as AWS services, peered VPCs, and on-premises networks. For each additional network, you must add a route to the network and configure an authorization rule to give clients access.

In this tutorial, add a route to the internet (0.0.0.0/0) and add an authorization rule that grants access to all users.

**To enable access to the internet**

**1.)** Open the Amazon VPC console at https://console.aws.amazon.com/vpc/.<br>
**2.)** In the navigation pane, choose **Client VPN Endpoints**.<br>
**3.)** Select the Client VPN endpoint to which to add the route, choose **Route Table**, and then choose **Create Route**.<br>
**4.)** For **Route destination**, enter 0.0.0.0/0. For **Target VPC Subnet ID**, specify the ID of the subnet through which to route traffic.
**5.)** Choose **Create Route**.
**6.)** Choose **Authorization**, and then choose **Authorize Ingress**.
**7.)** For **Destination network to enable**, enter 0.0.0.0/0, and choose **Allow access to all users**.
**8.)** Choose **Add authorization rule**.
**9.)** Ensure that the security group that's associated with subnet you are routing traffic through allows inbound and outbound traffic to and from the internet. To do this, add inbound and outbound rules that allow internet traffic to and from 0.0.0.0/0.
 

## **Step 6: Download the Client VPN endpoint configuration file** <a name="step-6-download-the-client-vpn-endpoint-configuration-file"></a>

The final step is to download and prepare the Client VPN endpoint configuration file. The configuration file includes the Client VPN endpoint and certificate information required to establish a VPN connection. You must provide this file to the clients who need to connect to the Client VPN endpoint to establish a VPN connection. The client uploads this file into their VPN client application.

**To download and prepare the Client VPN endpoint configuration file**

**1.)** Open the Amazon VPC console at https://console.aws.amazon.com/vpc/.<br>
**2.)** In the navigation pane, choose **Client VPN Endpoints**.<br>
**3.)** Select the Client VPN endpoint and choose **Download Client Configuration**.
**4.)** Locate the client certificate and key that were generated in Step 1. The client certificate and key can be found in the following locations in the cloned OpenVPN easy-rsa repo:<br>

- Client certificate — easy-rsa/easyrsa3/pki/issued/client1.domain.tld.crt
- Client key — easy-rsa/easyrsa3/pki/private/client1.domain.tld.key
 
**5.)** Open the Client VPN endpoint configuration file using your preferred text editor and add the contents of the client certificate between <cert></cert> tags and the contents of the private key between <key></key> tags.
 
<cert>
Contents of client certificate (.crt) file
</cert>

<key>
Contents of private key (.key) file
</key>
 

**NOTE -** In my config file these tags didn’t exist.  The video states to just add the following lines to the end of the file:

cert /Users/bamil1/easy-rsa/easyrsa3/acm/bamil.brokenpropellersaws.com.crt
key /Users/bamil1/easy-rsa/easyrsa3/acm/bamil.brokenpropellersaws.com.key

**6.)** Prepend a random string to the Client VPN endpoint DNS name. Locate the line that specifies the Client VPN endpoint DNS name, and prepend a random string to it so that the format is random_string.displayed_DNS_name. For example:

- Original DNS name: cvpn-endpoint-0102bc4c2eEXAMPLE.prod.clientvpn.us-west-2.amazonaws.com
- Modified DNS name: asdfa.cvpn-endpoint-0102bc4c2eEXAMPLE.prod.clientvpn.us-west-2.amazonaws.com

**7.)** Save and close the Client VPN endpoint configuration file.
**8.)** Distribute the Client VPN endpoint configuration file to your clients.


## **Step 7: Connect to the Client VPN endpoint** <a name="step-7-connect-to-the-client-vpn-endpoint"></a>

You can connect to the Client VPN endpoint using the AWS-provided client or another OpenVPN-based client application. For more information, see the AWS Client VPN User Guide.

- client and vpc CIDRs must not overlap
- vpn endpoint and associated VPC must be in the same AWS account
- associated subnets must be in the same VPC
- cannot associate multiple subnets from the same AZ
- only IPV4 traffic
- not HIPPA / FIPS compliant

Target Network = Subnet
VPN endpoint has Security Group attached
VPN endpoint will have a route table attached as well to allow access to specific clients

**NOTE -** DOES SUPPORT SPLIT Tunneling - ONLY AWS TRAFFIC ROUTES THROUGH THE VPN and all other user traffic can be routed as standard (like if you are viewing cnn.com or something that’s not secure).


## **TROUBLESHOOTING:** <a name="troubleshooting"></a>
- Make sure the VPC has an Internet Gateway configured (IGW) AND attached to the VPC
- Make sure the VPC has a Virtual Private Gateway (VGW) AND attached to the VPC
- Make sure to ADD the association and AUTHORIZE INGRESS items
- Make sure the route table has a route to the IGW for 0.0.0.0/0
- Double check route propogation for the VGW (in the route table)

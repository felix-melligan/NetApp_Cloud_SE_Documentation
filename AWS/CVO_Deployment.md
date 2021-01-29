* If you have a NAT instance, you must define an inbound security group rule that allows HTTPS traffic from the private subnet to the internet.
    * Outbound internet access for the HA mediator (relevant if considering High Availability Deployment)
* The HA mediator instance must have an outbound connection to the AWS EC2 service so it can assist with storage failover. To provide the connection, you can add a public IP address, specify a proxy server, or use a manual option.
* The manual option can be a NAT gateway or an interface VPC endpoint from the target subnet to the AWS EC2 service. For details about VPC endpoints, refer to AWS Documentation: Interface VPC Endpoints (AWS PrivateLink).

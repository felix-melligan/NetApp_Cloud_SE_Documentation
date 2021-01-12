# AWS Site To Site VPN

Video here: https://youtu.be/5YvcyBecQts

VPC -> Router -> Virtual Private Gateway -> VPN Connection -> Customer Gateway (customers vpn router on prem)

**1.)** Create VPG (Virtual Private Gateway)<br>
**2.)** Create certificate for the Customer Gateway (optional)<br>
**3.)** Create the Customer Gateway<br>

- name can by anything
- static routing
- ip is public ip of the vpn on the customer side
- must create the certificate to use
- device can be anything

BGP - Border Gateway Protocol 
ASN - Autonomous System Number 

**NOTE -** Customer Gateway must have a public IP

- Need ARN - Amazon Resource Name CERTIFICATE
- Use AWS Certificate Manager

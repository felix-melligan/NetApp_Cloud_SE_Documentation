# AWS Key Upload

Upload the server certificate and key and the client certificate and key to ACM. The following commands use the AWS CLI.

$ aws acm import-certificate --certificate fileb://server.crt --private-key fileb://server.key --certificate-chain fileb://ca.crt --region region

$ aws acm import-certificate --certificate fileb://client1.domain.tld.crt --private-key fileb://client1.domain.tld.key --certificate-chain fileb://ca.crt --region region

To upload the certificates using the ACM console, see Import a Certificate in the AWS Certificate Manager User Guide.

Note: Be sure to upload the certificates and keys in the same Region in which you intend to create the Client VPN endpoint.

You only need to upload the client certificate to ACM when the CA of the client certificate is different from the CA of the server certificate. In the steps above, the client certificate uses the same CA as the server certificate, however, the steps to upload the client certificate are included here for completeness.

Mine for first test:

bamil1@mbrandon-mac-0 acm % aws acm import-certificate --certificate fileb://brokenpropellersaws.com.crt --private-key fileb://brokenpropellersaws.com.key --certificate-chain fileb://ca.crt --region us-east-1
bamil1@mbrandon-mac-0 acm % aws acm import-certificate --certificate fileb://bamil.brokenpropellersaws.com.crt --private-key fileb://bamil.brokenpropellersaws.com.key --certificate-chain fileb://ca.crt --region us-east-1

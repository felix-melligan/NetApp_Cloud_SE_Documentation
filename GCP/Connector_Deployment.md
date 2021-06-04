<a name="top"></a>
# Prepare GCP Environment & Deploy Cloud Volumes ONTAP Service Connector in GCP ready for Cloud Volumes ONTAP Deployment

## Contents

* [Pre-Requisites](#pre-requisites)
  + [Single Node, No Shared VPC](#pre-requisites-sn-nsv)
  + [Single Node, Shared VPC](#pre-requisites-sn-sv)
  + [High Availability, No Shared VPC](#pre-requisites-ha-nsv)
  + [High Availability, Shared VPC](#pre-requisites-ha-sv)
  + [Allow APIs](#allow-apis)
  + [Extra Tips](#extra-tips)
* [IAM enablement](#iam-enablement)
  + [Exports](#exports)
  + [User Level](#user-level)
  + [Service Connector Level](#service-connector-level)
    + [Shared VPCs](#shared-vpc)
  + [Tiering Account](#tiering-account)
* [Create Service Connector](#create-service-connector)
  + [Create Connector through gcloud](#create-gcloud)
  + [Create Connector through Cloud Central](#create-cloud-central)
* [Deploy Cloud Volumes ONTAP](#deploy-cvo)

<div align="right">
    <b><a href="#top">↥ back to top</a></b>
</div>

---

## Pre-Requisites <a name="pre-requisites"></a>

### Pre-Requisites - Single Node, No Shared VPC <a name="pre-requisites-sn-nsv"></a>
- [ ] A Project
- [ ] At least one VPC
- [ ] At least 1 subnet in the region that you want to deploy Cloud Manager and CVO
  - [ ] 1 address per service connector
  - [ ] 5 addresses per CVO
  - [ ] Private Google Access to GCS for Tiering
  - [ ] External internet access from the VPC using Cloud NAT or a proxy from the service connector to <a href="https://docs.netapp.com/us-en/occm/reference_networking_gcp.html#requirements-for-the-connector">these endpoints</a>
- [ ] Permissions to assign IAM in the project linked to the VPC - *resourcemanager.projects.setIamPolicy* (Owner or Editor is fine)
- [ ] Billing account Admin (for PAYGO) to subscribe to Cloud Manager - *billing.admin*
- [ ] Enough quota of for CPUs of the machine type (n1/n2) and storage media (pd-standard/pd-ssd)
- [ ] (Optional) Firewall rules to enable access to the <a href="https://docs.netapp.com/us-en/occm/reference_networking_gcp.html#firewall-rules-for-the-connector">service connector</a> and <a href="https://docs.netapp.com/us-en/occm/reference_networking_gcp.html#firewall-rules-for-cloud-volumes-ontap">Cloud Volumes ONTAP</a>. These can be tag based, service account based or of type apply to all

<div align="right">
    <b><a href="#top">↥ back to top</a></b>
</div>

### Pre-Requisites - Single Node, Shared VPC <a name="pre-requisites-sn-sv"></a>
- [ ] A Host Project
- [ ] A Service Project
- [ ] At least one Shared VPC
- [ ] At least 1 shared subnet in the region that you want to deploy Cloud Manager and CVO
  - [ ] 1 address per service connector
  - [ ] 5 addresses per CVO
  - [ ] Private Google Access to GCS for Tiering
  - [ ] External internet access from the VPC using Cloud NAT or a proxy from the service connector to <a href="https://docs.netapp.com/us-en/occm/reference_networking_gcp.html#requirements-for-the-connector">these endpoints</a>
  - [ ] Permissions to assign IAM in the service project linked to the VPC - *resourcemanager.projects.setIamPolicy* (Owner or Editor is fine)
  - [ ] Permissions to assign IAM in the host project linked to the VPC - *resourcemanager.projects.setIamPolicy* (Owner or Editor is fine)
  - [ ] Billing account Admin (for PAYGO) to subscribe to Cloud Manager - *billing.admin*
  - [ ] Enough quota of for CPUs of the machine type (n1/n2) and storage media (pd-standard/pd-ssd)
- [ ] (Optional) Firewall rules to enable access to the <a href="https://docs.netapp.com/us-en/occm/reference_networking_gcp.html#firewall-rules-for-the-connector">service connector</a> and <a href="https://docs.netapp.com/us-en/occm/reference_networking_gcp.html#firewall-rules-for-cloud-volumes-ontap">Cloud Volumes ONTAP</a>. These can be tag based, service account based or of type apply to all

<div align="right">
    <b><a href="#top">↥ back to top</a></b>
</div>

### Pre-Requisites - High Availability (2 Nodes), No Shared VPC <a name="pre-requisites-ha-nsv"></a>
- [ ] A Project
- [ ] At least 4 VPCs:
  - VPC0 (Data Serving Network):
    - [ ] At least 1 subnet in the region that you want to deploy Cloud Manager and CVO
      - [ ] 1 address per service connector
      - [ ] 8 addresses per CVO HA pair
      - [ ] Private Google Access to GCS for Tiering
      - [ ] External internet access from the VPC using Cloud NAT or a proxy from the service connector to <a href="https://docs.netapp.com/us-en/occm/reference_networking_gcp.html#requirements-for-the-connector">these endpoints</a>
  - VPC1 (Intercluster communications, private network):
    - [ ] At least 1 subnet in the region that you want to deploy Cloud Manager and CVO
      - [ ] 2 addresses per CVO HA pair
  - VPC2 (NVRAM traffic, private network):
    - [ ] At least 1 subnet in the region that you want to deploy Cloud Manager and CVO
      - [ ] 2 addresses per CVO HA pair
  - VPC3 (Disk Replication & Mediator, private network):
    - [ ] At least 1 subnet in the region that you want to deploy Cloud Manager and CVO
      - [ ] 3 addresses per CVO HA pair
- [ ] Permissions to assign IAM in the project linked to the VPC - *resourcemanager.projects.setIamPolicy* (Owner or Editor is fine)
- [ ] Billing account Admin (for PAYGO) to subscribe to Cloud Manager - *billing.admin*
- [ ] Enough quota of for CPUs of the machine type (n1/n2), storage media (pd-standard/pd-ssd) and Backend Services (8 per CVO HA pair)
- [ ] (Optional) Firewall rules to enable access to the <a href="https://docs.netapp.com/us-en/occm/reference_networking_gcp.html#firewall-rules-for-the-connector">service connector</a> and <a href="https://docs.netapp.com/us-en/occm/reference_networking_gcp.html#firewall-rules-for-cloud-volumes-ontap">Cloud Volumes ONTAP</a>. These can be tag based, service account based or of type apply to all
- [ ] (Optional) Firewall rules for <a href="https://docs.netapp.com/us-en/occm/reference_networking_gcp.html#firewall-rules-for-vpc-1-vpc-2-and-vpc-3">VPC1, VPC2 and VPC3</a>. These can be tag based, service account based or of type apply to all

>:grey_exclamation: Note: Ensure that the firewall for VPC0 has access to the Google Internal LoadBalancer health check IP ranges

<div align="right">
    <b><a href="#top">↥ back to top</a></b>
</div>

### Pre-Requisites - High Availability (2 Nodes), Shared VPC <a name="pre-requisites-ha-sv"></a>
- [ ] A Host Project
- [ ] A Service Project
- [ ] At least 4 VPCs:
  - VPC0 (**Shared** Data Serving Network):
    - [ ] At least 1 shared subnet in the region that you want to deploy Cloud Manager and CVO
      - [ ] 1 address per service connector
      - [ ] 8 addresses per CVO HA pair
      - [ ] Private Google Access to GCS for Tiering
      - [ ] External internet access from the shared VPC using Cloud NAT or a proxy from the service connector to <a href="https://docs.netapp.com/us-en/occm/reference_networking_gcp.html#requirements-for-the-connector">these endpoints</a>
  - VPC1 (**Optionally Shared** Intercluster communications, private network):
    - [ ] At least 1 subnet in the region that you want to deploy Cloud Manager and CVO
      - [ ] 2 addresses per CVO HA pair
  - VPC2 (**Optionally Shared** NVRAM traffic, private network):
    - [ ] At least 1 subnet in the region that you want to deploy Cloud Manager and CVO
      - [ ] 2 addresses per CVO HA pair
  - VPC3 (**Optionally Shared** Disk Replication & Mediator, private network):
    - [ ] At least 1 subnet in the region that you want to deploy Cloud Manager and CVO
      - [ ] 3 addresses per CVO HA pair
- [ ] Permissions to assign IAM in the service project linked to the VPC - *resourcemanager.projects.setIamPolicy* (Owner or Editor is fine)
- [ ] Permissions to assign IAM in the host project linked to the VPC - *resourcemanager.projects.setIamPolicy* (Owner or Editor is fine)
- [ ] Billing account Admin (for PAYGO) to subscribe to Cloud Manager - *billing.admin*
- [ ] Enough quota of for CPUs of the machine type (n1/n2), storage media (pd-standard/pd-ssd) and Backend Services (8 per CVO HA pair) in the service project
- [ ] (Optional) Firewall rules in the host project to enable access to the <a href="https://docs.netapp.com/us-en/occm/reference_networking_gcp.html#firewall-rules-for-the-connector">service connector</a> and <a href="https://docs.netapp.com/us-en/occm/reference_networking_gcp.html#firewall-rules-for-cloud-volumes-ontap">Cloud Volumes ONTAP</a>. These can be tag based, service account based or of type apply to all
- [ ] (Optional) Firewall rules for <a href="https://docs.netapp.com/us-en/occm/reference_networking_gcp.html#firewall-rules-for-vpc-1-vpc-2-and-vpc-3">VPC1, VPC2 and VPC3</a>. These can be tag based, service account based or of type apply to all

> :grey_exclamation: Note: Ensure that the firewall for VPC0 has access to the Google Internal LoadBalancer health check IP ranges

<div align="right">
    <b><a href="#top">↥ back to top</a></b>
</div>

### Allow APIs <a name="allow-apis"></a>
- Add APIs: ```gcloud services enable deploymentmanager.googleapis.com logging.googleapis.com cloudresourcemanager.googleapis.com compute.googleapis.com iam.googleapis.com cloudkms.googleapis.com ```
- Show APIs: ```gcloud services list ```
>	For Shared VPC deployments, also enable to APIs on the host project
>- Enable the APIs on the host project: ``` gcloud services enable --project $hostProject deploymentmanager.googleapis.com logging.googleapis.com cloudresourcemanager.googleapis.com compute.googleapis.com iam.googleapis.com ```
>- Show APIs: ```gcloud services list ```

<div align="right">
    <b><a href="#top">↥ back to top</a></b>
</div>

---

### :bulb: Extra Tips <a name="extra-tips"></a>

#### Restricted access to external projects <a name="external-projects"></a>
- If the project that you are deploying Cloud Manager and Cloud Volumes ONTAP has restricted access to external projects, then you will need to whitelist the project: netapp-cloudmanager. This is the project that we hold the CVO and Cloud Manager GCE images to deploy the service connector and CVO
- If whitelisting is impossible, you may have to deploy the service connector using a <a href="https://docs.netapp.com/us-en/occm/task_installing_linux.html">linux host</a>. You would also then need to create a CVO and mediator image yourself by pulling the image from the above project and into a local GCS bucket

#### Proxy information <a name="proxy-info"></a>
- If you are using a proxy, then either no authentication or basic authentication is supported. NTLM authentication is NOT supported.
- If your proxy does packet inspection, then the service connector will need to be whitelisted so that no packet manipulation occurs
- You can also apply a CA signed certificate to the service connector to allow traffic through your proxy. This can be achieved either during set up on the proxy screen or through the Cloud Manager settings page

#### When you need to deploy via the API
If you have any of the following requirements, you will need to deploy CVO via the API:
- Using Google CMEK to encrypt the CVO disks
- Using a shared VPC for VPC1, VPC2 or VPC3

<div align="right">
    <b><a href="#top">↥ back to top</a></b>
</div>

---

## IAM enablement <a name="iam-enablement"></a>
- Get policy from: https://mysupport.netapp.com/site/info/cloud-manager-policies:
  - User policy: ```curl https://occm-sample-policies.s3.amazonaws.com/Setup_As_Service_3.7.3_GCP.yaml -o NetAppUserPolicy.yaml ```
  - SC policy: ```curl https://occm-sample-policies.s3.amazonaws.com/Policy_for_Cloud_Manager_3.9.0_GCP.yaml -o NetAppSCPolicy.yaml ```

### Exports <a name="exports"></a>
Enables you to run gcloud commands without constantly editing them before running them
- Export variables:  
  - Service Project/Current Project: ```project=`gcloud config list --format 'value(core.project)' 2>/dev/null` ```
  - Host Project (Optional): ```hostProject=[ENTER YOUR HOST PROJECT HERE] ```
  - User email: ```user=`gcloud config list --format 'value(core.account)' 2>/dev/null` ```
  - IAM user role name: ```userRole=netappuserrole ```
  - IAM service connector role name: ```connectorRole=netappscrole ```
  - IAM service connector service account name: ```connectorServiceAccount=netapp-service-connector ```
  - IAM ONTAP node service account name: ```cvoServiceAccount=netapp-cloud-volumes-ontap ```

### User Level <a name="user-level"></a>
- Download User policy from Support site and upload to gcloud (If you didn't use curl)
- Create role: ```gcloud iam roles create $userRole --project=$project --file NetAppUserPolicy.yaml ```
- Assign role to user: ```gcloud projects add-iam-policy-binding $project --member=user:$user --role=projects/$project/roles/$userRole ```

### Service Connector Level <a name="service-connector-level"></a>
- Download GCP SC policy and upload to gcloud console (If you didn't use curl)
- Create Role: ```gcloud iam roles create $connectorRole --project $project --file NetAppSCPolicy.yaml ```
- Create Service Account: ```gcloud iam service-accounts create $connectorServiceAccount --description="Allows NetApp Service Connector to deploy and manage Cloud Volumes ONTAP instances" --display-name="NetApp Service Connector" ```
- Assign role to service connector: ```gcloud projects add-iam-policy-binding $project --member=serviceAccount:connectorServiceAccount --role=projects/$project/roles/$connectorRole ```

**A note on Shared VPCs** <a name="shared-vpc"></a>
>	#### If you are deploying into a shared VPC and have performed the above stages on a service project, you need to:
>	- Allow the service connector service account permissions on the host project: ``` gcloud projects add-iam-policy-binding $hostProject --member=serviceAccount:$connectorServiceAccount@$project --role=roles/compute.networkUser ```
>	- Allow the service connector service account permissions on the host project: ``` gcloud projects add-iam-policy-binding $hostProject --member=serviceAccount:$connectorServiceAccount@$project --role=roles/deploymentmanager.editor ```
>	- Allow default service accounts permissions in host project:
>	  - ``` computeEngineDefaultAccount=`gcloud iam service-accounts list --project $project --format 'value(email)' --filter 'displayName:"Compute Engine default service account"' 2>/dev/null` ```
>	  - ``` gcloud projects add-iam-policy-binding $hostProject --member=serviceAccount:$computeEngineDefaultAccount --role=roles/compute.networkUser ```

### Tiering Account <a name="tiering-account"></a>
- Create Tiering Service Account: ``` gcloud iam service-accounts create $cvoServiceAccount --description="Allows NetApp Cloud Volumes ONTAP instance to tier to GCS" --display-name="NetApp Cloud Volumes ONTAP" ```
- Assign Storge Admin role to service account: ``` gcloud projects add-iam-policy-binding $project --member=serviceAccount:$cvoServiceAccount --role=roles/storage.admin ```
- Assign SC service account to Tiering account as user: ``` gcloud iam service-accounts add-iam-policy-binding $cvoServiceAccount --member=serviceAccount:$connectorServiceAccount --role=roles/iam.serviceAccountUser ```

<div align="right">
    <b><a href="#top">↥ back to top</a></b>
</div>

---

## Create Service Connector <a name="create-service-connector"></a>

### Create Service Connector locally through gcloud <a name="create-gcloud"></a>
This will enable you to deploy the cloud manager service connector directly from GCP referencing an image from the NetApp image repository in the project netapp-cloudmanager.

>:grey_exclamation: Note: you will need to be able to access the service connector VM from a web browser (port 80) to complete the deployment without APIs.

- Exports:
  - ``` instanceName=cloudmanager ```
  - ``` zone=$zone ```
- Deploy Service Connector: ``` gcloud compute instances create $instanceName --machine-type=n1-standard-4 --zone=$zone --image-project=netapp-cloudmanager --image-family=cloudmanager --service-account=$connectorServiceAccount@$project.iam.gserviceaccount.com --scopes=cloud-platform ```
>**Extra Parameters (optional)**
>  - ``` --no-address ``` - No external IP address is used (Need a cloud NAT or proxy to route traffic to public internet)
>  - ``` --tags ``` - Add network tagging to link a firewall rule using tags to the connector instance
>  - ``` --network ``` - Add the name of the network to deploy the service connector into (For Shared VPC you need the full path)
>  - ``` --subnet ``` - Add the subnet name to deploy the service connector into (For Shared VPC you need the full path)
>  - ``` --boot-disk-kms-key ``` - Add a kms key to encrypt the service connector disks (IAM permissions also need to be applied)

- Once deployed, log into the local UI using your login from <a href="https://cloud.netapp.com">NetApp Cloud Central</a>
- If there is no internet access:
 - A pop up will appear prompting you to fill in your proxy credentials
 - You can also optionally create a certificate signing request and upload a CA signed certificate
 - If the pop up does not disappear, validate that the proxy information is correct and all required endpoints are available
- Set Account information and name the service connector (For reference in Cloud Manager SaaS)
- Registration will occur and initial setup
- The service connector will now be available to deploy Cloud Volumes ONTAP

<div align="right">
    <b><a href="#top">↥ back to top</a></b>
</div>

---

### Create Service Connector through Cloud Central <a name="create-cloud-central"></a>
This will enable you to deploy Cloud Manager through NetApp Cloud Central.

- Navigate to <a href="https://cloudmanager.netapp.com">Cloud Manager SaaS</a>
- <a href="https://docs.netapp.com/us-en/occm/task_creating_connectors_gcp.html#creating-a-connector-in-gcp">Follow the guide</a> to deploy the service connector

<div align="right">
    <b><a href="#top">↥ back to top</a></b>
</div>

---

## Deploy Cloud Volumes ONTAP <a name="deploy-cvo"></a>
This will enable you to deploy CVO from Cloud Manager,

- Navigate to <a href="https://cloudmanager.netapp.com">Cloud Manager SaaS</a> or the local cloud manager UI through a web browser
- <a href="https://docs.netapp.com/us-en/occm/task_deploying_gcp.html">Follow this guide</a> to deploy Cloud Volumes ONTAP

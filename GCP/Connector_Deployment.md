# Prepare GCP Environment & Deploy Cloud Volumes ONTAP Service Connector in GCP ready for Cloud Volumes ONTAP Deployment


* [Pre-Requisites](#pre-requisites)
  + [Single Node, No Shared VPC](#pre-requisites-sn-nsv)
* [Allow APIs](#allow-apis)
* [IAM enablement](#iam-enablement)
  + [Exports](#exports)
  + [User Level](#user-level)
  + [Service Connector Level](#service-connector-level)
  + [Shared VPCs](#shared-vpc)
  + [Tiering Account](#tiering-account)
* [Create Service Connector](#create-service-connector)

## Pre-Requisites <a name="pre-requisites"></a>

### Pre-Requisites - Single Node, No Shared VPC <a name="pre-requisites-sn-nsv"></a>
- A Project
- At least one VPC
- At least 1 subnet in the region that you want to deploy Cloud Manager and CVO
  - 1 address per service connector
  - 5 addresses per CVO
  - Private Google Access to GCS for Tiering
- Permissions to assign IAM in the project linked to the VPC - *resourcemanager.projects.setIamPolicy* (Owner or Editor is fine)
- Billing account Admin (for PAYGO) to subscribe to Cloud Manager - *billing.admin*
- Enough quota of for CPUs of the machine type (n1/n2) and storage media (pd-standard/pd-ssd)

## Allow APIs <a name="allow-apis"></a>
- Add APIs: ```gcloud services enable deploymentmanager.googleapis.com logging.googleapis.com cloudresourcemanager.googleapis.com compute.googleapis.com iam.googleapis.com cloudkms.googleapis.com ```
- Show APIs: ```gcloud services list ```

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
>	- Enable the APIs on the host project: ``` gcloud services enable --project $hostProject deploymentmanager.googleapis.com logging.googleapis.com cloudresourcemanager.googleapis.com compute.googleapis.com iam.googleapis.com ```
>	- Allow the service connector service account permissions on the host project: ``` gcloud projects add-iam-policy-binding $hostProject --member=serviceAccount:$connectorServiceAccount@$project --role=roles/compute.networkUser ```
>	- Allow the service connector service account permissions on the host project: ``` gcloud projects add-iam-policy-binding $hostProject --member=serviceAccount:$connectorServiceAccount@$project --role=roles/deploymentmanager.editor ```
>	- Allow default service accounts permissions in host project: 
>	  - ``` computeEngineDefaultAccount=`gcloud iam service-accounts list --project $project --format 'value(email)' --filter 'displayName:"Compute Engine default service account"' 2>/dev/null` ```
>	  - ``` gcloud projects add-iam-policy-binding $hostProject --member=serviceAccount:$computeEngineDefaultAccount --role=roles/compute.networkUser ```

### Tiering Account <a name="tiering-account"></a>
- Create Tiering Service Account: ``` gcloud iam service-accounts create $cvoServiceAccount --description="Allows NetApp Cloud Volumes ONTAP instance to tier to GCS" --display-name="NetApp Cloud Volumes ONTAP" ```
- Assign Storge Admin role to service account: ``` gcloud projects add-iam-policy-binding $project --member=serviceAccount:$cvoServiceAccount --role=roles/storage.admin ```
- Assign SC service account to Tiering account as user: ``` gcloud iam service-accounts add-iam-policy-binding $cvoServiceAccount --member=serviceAccount:$connectorServiceAccount --role=roles/iam.serviceAccountUser ```

# Deploy CVO <a name="deploy-cvo"></a>

## Create Service Connector <a name="create-service-connector"></a>

### Create Service Connector locally through gcloud
- Exports:
  - ``` instanceName=cloudmanager ```
  - ``` zone=$zone ``
- Deploy Service Connector: ``` gcloud compute instances create $instanceName --machine-type=n1-standard-4 --zone=$zone --image-project=netapp-cloudmanager --image-family=cloudmanager --service-account=$connectorServiceAccount@$project.iam.gserviceaccount.com --scopes=cloud-platform ```
**Extra Params**
>	- Optional GCE params (not exhaustive)
>	  - ``` --no-address ``` - No external IP address is used (Need a cloud NAT or proxy to route traffic to public internet)
>	  - ``` --tags ``` - Add network tagging to link a firewall rule using tags to the connector instance
>	  - ``` --network ``` - Add the name of the network to deploy the service connector into (For Shared VPC you need the full path)
>	  - ``` --subnet ``` - Add the subnet name to deploy the service connector into (For Shared VPC you need the full path)
>	  - ``` --boot-disk-kms-key ``` - Add a kms key to encrypt the service connector disks (IAM permissions also need to be applied)



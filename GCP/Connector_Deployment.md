# Deploy Cloud Volumes ONTAP Service Connector in GCP


* [Pre-Requisites](#pre-requisites)
* [Exports](#exports)
* [Allow APIs](#allow-apis)
* [IAM enablement](#iam-enablement)
  + [User Level](#user-level)
  + [Service Connector Level](#service-connector-level)
  + [Tiering Account](#tiering-account)
* [Create Service Connector](#create-service-connector)

## Pre-Requisites <a name="pre-requisites"></a>
- A Project
- At least one VPC
- At least 1 subnet
- Permissions to assign IAM in all projects linked ot the VPC - *resourcemanager.projects.setIamPolicy*
- Billing account Admin (for PAYGO) to subscribe to Cloud Manager - *billing.admin*

## Exports <a name="exports"></a>
- Export variables:  
  - Project: ```project=`gcloud config list --format 'value(core.project)' 2>/dev/null` ```
  - User email: ```user=`gcloud config list --format 'value(core.account)' 2>/dev/null` ```

## Allow APIs <a name="allow-apis"></a>
- Add APIs: ```gcloud services enable deploymentmanager.googleapis.com logging.googleapis.com cloudresourcemanager.googleapis.com compute.googleapis.com iam.googleapis.com cloudkms.googleapis.com ```
- Show APIs: ```gcloud services list ```

## IAM enablement <a name="iam-enablement"></a>
- Get policy from: https://mysupport.netapp.com/site/info/cloud-manager-policies:
  - User policy: ```curl https://occm-sample-policies.s3.amazonaws.com/Setup_As_Service_3.7.3_GCP.yaml -o NetAppUserPolicy.yaml ```
  - SC policy: ```curl https://occm-sample-policies.s3.amazonaws.com/Policy_for_Cloud_Manager_3.9.0_GCP.yaml -o NetAppSCPolicy.yaml ```
		
### User Level <a name="user-level"></a>
- Download User policy from Support site and upload to gcloud (If you didn't use curl)
- Create role: ```gcloud iam roles create netappuserrole --project=$project --file NetAppUserPolicy.yaml ```
- Assign role to user: ```gcloud projects add-iam-policy-binding $project --member=user:$user --role=projects/$project/roles/netappuserrole ```
### Service Connector Level <a name="service-connector-level"></a>
- Download GCP SC policy and upload to gcloud console (If you didn't use curl)
- Create Role: ```gcloud iam roles create netappscrole --project $project --file NetAppSCPolicy.yaml ```
- Create Service Account: ```gcloud iam service-accounts create netapp-service-connector --description="Allows NetApp Service Connector to deploy and manage Cloud Volumes ONTAP instances" --display-name="NetApp Service Connector" ```
- Assign role to service connector: ```gcloud projects add-iam-policy-binding $project --member=serviceAccount:$serviceAccount --role=projects/$project/roles/netappscrole ```

**A note on Shared VPCs**
>	#### If you are deploying into a shared VPC and have performed the above stages on a service project, you need to:
>	- Enable the APIs on the host project: ``` gcloud services enable --project $hostProject deploymentmanager.googleapis.com logging.googleapis.com cloudresourcemanager.googleapis.com compute.googleapis.com iam.googleapis.com ```
>	- Allow the service connector account netappscrole permissions on the host project: ``` gcloud projects add-iam-policy-binding $hostProject --member=serviceAccount:$scServiceAccount@serviceProject --role=roles/compute.networkUser ```
>	- Allow the service connector account netappscrole permissions on the host project: ``` gcloud projects add-iam-policy-binding $hostProject --member=serviceAccount:$scServiceAccount@serviceProject --role=roles/deploymentmanager.editor ```
>	- Allow default service accounts permissions in host project: 
>	  - ``` COMPUTE_ENGINE_SERVICE_ACCOUNT=`gcloud iam service-accounts list --format 'value(email)' --filter 'displayName:"Compute Engine default service account"' 2>/dev/null` ```
>	  - ``` gcloud projects add-iam-policy-binding $HOST_PROJECT --member=serviceAccount:$COMPUTE_ENGINE_SERVICE_ACCOUNT --role=roles/compute.networkUser ```

### Tiering Account <a name="tiering-account"></a>
- Create Tiering Service Account: ``` gcloud iam service-accounts create netapp-cloud-volumes-ontap --description="Allows NetApp Cloud Volumes ONTAP instance to tier to GCS" --display-name="NetApp Cloud Volumes ONTAP" ```
- Assign Storge Admin role to service account: ``` gcloud projects add-iam-policy-binding $project --member=serviceAccount:$serviceAccount --role=roles/storage.admin ```
- Assign SC service account to Tiering account as user: ``` gcloud iam service-accounts add-iam-policy-binding $tieringServiceAccount --member=serviceAccount:$serviceConnectorAccount --role=roles/iam.serviceAccountUser ```

# Deploy CVO <a name="deploy-cvo"></a>

## Create Service Connector <a name="create-service-connector"></a>
- Exports:
  - ``` instanceName=cloudmanager ```
  - ``` zone=$zone ``
- Deploy Service Connector: ``` gcloud compute instances create $instanceName --machine-type=n1-standard-4 --zone=$zone   --image-project=netapp-cloudmanager --image-family=cloudmanager      --tags=http-server,https-server  --service-account=serviceaccountcm@tlv-support.iam.gserviceaccount.com --scopes=cloud-platform ```
- Get External IP: ``` gcloud compute instances describe $instanceName --zone $zone --format='get(networkInterfaces[0].accessConfigs[0].natIP)' ```
- Get internal IP: ``` gcloud compute instances describe $instanceName --zone $zone --format='get(networkInterfaces[0].networkIP)' ```
- Set IP value: ``` occmIp=`gcloud compute instances describe $instanceName --zone $zone --format='get(networkInterfaces[0].accessConfigs[0].natIP)'` ```
- Ensure connectivity: ``` until sudo wget http://$occmIp/occmui > /dev/null 2>&1; do sudo wget http://$occmIp > /dev/null 2>&1 ; done ```

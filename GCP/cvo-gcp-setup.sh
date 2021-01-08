# Set Variables
PROJECT="default"
HOST_PROJECT="default"
NETWORK="default"
SUBNET="default"
REGION="us-east4"
ZONE="us-east4-a"
USER_EMAIL="default"
USER_ROLE_NAME="netappuserrole"
SERVICE_CONNECTOR_ROLE_NAME="netappscrole"
SERVICE_CONNECTOR_SERVICE_ACCOUNT_NAME="netapp-service-connector"
CVO_SERVICE_ACCOUNT_NAME="netapp-cloud-volumes-ontap"
USER_POLICY_LINK="https://occm-sample-policies.s3.amazonaws.com/Setup_As_Service_3.7.3_GCP.yaml"
SC_POLICY_LINK="https://occm-sample-policies.s3.amazonaws.com/Policy_for_Cloud_Manager_3.9.0_GCP.yaml"
SERVICE_CONNECTOR_INSTANCE_NAME="netapp-service-connector"
SHARED_VPC=0

function welcome {
    echo "Hello, $USER!"
    echo "This script will prepare your Google project to deploy Cloud Volumes ONTAP and the Service Connector, would you like to keep the default settings (Yes if already changed variables)?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) echo "Please change the settings, goodbye!"; exit;;
        esac
    done
}

function shared_vpc_choice {
    echo "Would you like to deploy into a shared VPC?"
        select yn in "Yes" "No"; do
        case $yn in
            Yes ) SHARED_VPC=1; correct_project_choice; break;;
            No ) break;;
        esac
    done
}

function correct_project_choice {
    printf "Are these values correct? \n\
        Service Project: $PROJECT \n\
        Host Project: $HOST_PROJECT \n\
        Network: $NETWORK \n\
        Subnet: $SUBNET \n"
        select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) echo "Please set the project to the service project and set all variables within this script"; exit;;
        esac
    done
}

function set_variables {
    test "$PROJECT" == "default" && PROJECT=`gcloud config list --format 'value(core.project)' 2>/dev/null`
    echo "Project set to: $PROJECT"
    test "$USER_EMAIL" == "default" && USER_EMAIL=`gcloud config list --format 'value(core.account)' 2>/dev/null`
    echo "User set to: $USER_EMAIL"
}

function enable_apis {
    echo "Enabling APIs"
    gcloud services enable deploymentmanager.googleapis.com logging.googleapis.com cloudresourcemanager.googleapis.com compute.googleapis.com iam.googleapis.com
    test $SHARED_VPC == 1 && gcloud services enable --project=$HOST_PROJECT deploymentmanager.googleapis.com logging.googleapis.com cloudresourcemanager.googleapis.com compute.googleapis.com iam.googleapis.com
}

function download_policies {
    echo "Downloading policies"
    curl $USER_POLICY_LINK -o NetAppUserPolicy.yaml
    curl $SC_POLICY_LINK -o NetAppSCPolicy.yaml
}

function set_user_permissions {
    echo "Setting user permissions"
    gcloud iam roles create $USER_ROLE_NAME --project=$PROJECT --file NetAppUserPolicy.yaml
    gcloud projects add-iam-policy-binding $PROJECT --member=user:$USER_EMAIL --role=projects/$PROJECT/roles/$USER_ROLE_NAME
    if test $SHARED_VPC == 1
        then
            gcloud iam roles create $USER_ROLE_NAME --project=$HOST_PROJECT --file NetAppUserPolicy.yaml
            gcloud projects add-iam-policy-binding $HOST_PROJECT --member=user:$USER_EMAIL --role=projects/$HOST_PROJECT/roles/$USER_ROLE_NAME
    fi
}

function set_service_connector_permissions {
    echo "Setting service connector permissions"
    gcloud iam roles create $SERVICE_CONNECTOR_ROLE_NAME --project $PROJECT --file NetAppSCPolicy.yaml
    gcloud iam service-accounts create $SERVICE_CONNECTOR_SERVICE_ACCOUNT_NAME --description="Allows NetApp Service Connector to deploy and manage Cloud Volumes ONTAP instances" --display-name="NetApp Service Connector"
    gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:$SERVICE_CONNECTOR_SERVICE_ACCOUNT_NAME@$PROJECT.iam.gserviceaccount.com --role=projects/$PROJECT/roles/$SERVICE_CONNECTOR_ROLE_NAME
    if test $SHARED_VPC == 1
        then
            gcloud projects add-iam-policy-binding $HOST_PROJECT --member=serviceAccount:$SERVICE_CONNECTOR_SERVICE_ACCOUNT_NAME@$PROJECT.iam.gserviceaccount.com --role=roles/compute.networkUser
            gcloud projects add-iam-policy-binding $HOST_PROJECT --member=serviceAccount:$SERVICE_CONNECTOR_SERVICE_ACCOUNT_NAME@$PROJECT.iam.gserviceaccount.com --role=roles/deploymentmanager.editor
            COMPUTE_ENGINE_SERVICE_ACCOUNT=`gcloud iam service-accounts list --format 'value(email)' --filter 'displayName:"Compute Engine default service account"' 2>/dev/null`
            gcloud projects add-iam-policy-binding $HOST_PROJECT --member=serviceAccount:$COMPUTE_ENGINE_SERVICE_ACCOUNT --role=roles/compute.networkUser
    fi
}

function set_tiering_account_permissions {
    echo "Setting CVO permissions"
    gcloud iam service-accounts create $CVO_SERVICE_ACCOUNT_NAME --description="Allows NetApp Cloud Volumes ONTAP instance to tier to GCS" --display-name="NetApp Cloud Volumes ONTAP"
    gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:$CVO_SERVICE_ACCOUNT_NAME@$PROJECT.iam.gserviceaccount.com --role=roles/storage.admin
    gcloud iam service-accounts add-iam-policy-binding $CVO_SERVICE_ACCOUNT_NAME@$PROJECT.iam.gserviceaccount.com --member=serviceAccount:$SERVICE_CONNECTOR_SERVICE_ACCOUNT_NAME@$PROJECT.iam.gserviceaccount.com --role=roles/iam.serviceAccountUser
}

function deploy_service_connector_choice {
    PUBLIC_IP=0
    echo "Would you like to deploy the Service Connector from here?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) echo "Configuration complete, goodbye!"; exit;;
        esac
    done

    echo "Would you like to assign a public IP?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) echo "Public IP will be assigned";
                PUBLIC_IP=1;
                if test $SHARED_VPC == 1
                    then
                        gcloud compute instances create $SERVICE_CONNECTOR_INSTANCE_NAME \
                        --machine-type=n1-standard-4 \
                        --zone=$ZONE \
                        --network=projects/$HOST_PROJECT/global/networks/$NETWORK \
                        --subnet=projects/$HOST_PROJECT/regions/$REGION/subnetworks/$SUBNET \
                        --image-project=netapp-cloudmanager \
                        --image-family=cloudmanager \
                        --tags=http-server,https-server \
                        --service-account=$SERVICE_CONNECTOR_SERVICE_ACCOUNT_NAME@$PROJECT.iam.gserviceaccount.com\
                        --scopes=cloud-platform;
                else
                    gcloud compute instances create $SERVICE_CONNECTOR_INSTANCE_NAME \
                    --machine-type=n1-standard-4 \
                    --zone=$ZONE \
                    --network=$NETWORK \
                    --subnet=$SUBNET \
                    --image-project=netapp-cloudmanager \
                    --image-family=cloudmanager \
                    --tags=http-server,https-server \
                    --service-account=$SERVICE_CONNECTOR_SERVICE_ACCOUNT_NAME@$PROJECT.iam.gserviceaccount.com\
                    --scopes=cloud-platform;
                fi
                break;;
            No ) echo "Private IP only being used"; \
                if test $SHARED_VPC == 1
                    then
                        gcloud compute instances create $SERVICE_CONNECTOR_INSTANCE_NAME \
                        --machine-type=n1-standard-4 \
                        --zone=$ZONE \
                        --network=projects/$HOST_PROJECT/global/networks/$NETWORK \
                        --subnet=projects/$HOST_PROJECT/regions/$REGION/subnetworks/$SUBNET \
                        --no-address \
                        --image-project=netapp-cloudmanager \
                        --image-family=cloudmanager \
                        --tags=http-server,https-server \
                        --service-account=$SERVICE_CONNECTOR_SERVICE_ACCOUNT_NAME@$PROJECT.iam.gserviceaccount.com\
                        --scopes=cloud-platform;
                else
                    gcloud compute instances create $SERVICE_CONNECTOR_INSTANCE_NAME \
                    --machine-type=n1-standard-4 \
                    --zone=$ZONE \
                    --network=$NETWORK \
                    --subnet=$SUBNET \
                    --no-address \
                    --image-project=netapp-cloudmanager \
                    --image-family=cloudmanager \
                    --tags=http-server,https-server \
                    --service-account=$SERVICE_CONNECTOR_SERVICE_ACCOUNT_NAME@$PROJECT.iam.gserviceaccount.com\
                    --scopes=cloud-platform;
                fi
                break;;
        esac
    done

    echo "Service connector being deployed!"
    gcloud compute instances describe $SERVICE_CONNECTOR_INSTANCE_NAME --zone $ZONE
}

function goodbye {
    echo "Thank you for using the GCP Service Connector deployment script, goodbye!"
}

function main {
    welcome
    set_variables
    shared_vpc_choice
    enable_apis
    download_policies
    set_user_permissions
    set_service_connector_permissions
    set_tiering_account_permissions
    deploy_service_connector_choice
    goodbye
}

main

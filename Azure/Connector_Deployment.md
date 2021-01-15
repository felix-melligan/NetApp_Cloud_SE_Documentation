# CVO Azure Deployment Playbook Guide

* [Creating a Connector in Azure from Cloud Manager](#creating-a-connector-in-azure-from-cloud-manager)
* [Creating a Connector from the Azure Marketplace](#Creating-a-Connector-from-the-Azure-Marketplace)
* [Installing the Connector software on an existing Linux host](#Installing-the-Connector-software-on-an-existing-Linux-host)
* [Planning your Cloud Volumes ONTAP configuration in Azure](#Planning-your-Cloud-Volumes-ONTAP-configuration-in-Azure)
	+ [Choosing a license type](#Choosing-a-license-type)
		+ [Supported configurations for Cloud Volumes ONTAP 9.8 in Azure](https://docs.netapp.com/us-en/cloud-volumes-ontap/reference_configs_azure_98.html)
	+ [Supported VM types](#Supported-VM-types) 
		+ [Supported configurations for Cloud Volumes ONTAP 9.8 in Azure](https://docs.netapp.com/us-en/cloud-volumes-ontap/reference_configs_azure_98.html)
	+ [Understanding storage limits](#Understanding-storage-limits) 
		+ [Storage limits for Cloud Volumes ONTAP 9.8 in Azure](https://docs.netapp.com/us-en/cloud-volumes-ontap/reference_limits_azure_98.html)
	+ [Sizing your system in Azure](#Sizing-your-system-in-Azure)
		+ Virtual machine type
			+ [General purpose virtual machine sizes](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes-general#dsv2-series)
			+ [Memory optimized virtual machine sizes](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes-memory#dsv2-series-11-15)
* [Launching Cloud Volumes ONTAP in Azure](#Launching-Cloud-Volumes-ONTAP-in-Azure)
			
## Creating a Connector in Azure from Cloud Manager <a name="creating-a-connector-in-azure-from-cloud-manager"></a>

### Networking requirements for the Connector in Azure

- Networking Requirements for the Connector
	+ Networking Requirements for the Connector 
		+ Configuring the Connector to use a proxy server
		+ Connections to target networks
		+ Outbound internet access
		
- Security group rules for the Connector
	+ Inbound rules
	+ Outbound rules
		+ Basic outbound rules
		+ Advanced outbound rules

## Creating a Connector from the Azure Marketplace <a name="Creating-a-Connector-from-the-Azure-Marketplace"></a>

### Networking requirements for the Connector in Azure

- Networking Requirements for the Connector
	+ Networking Requirements for the Connector 
		+ Configuring the Connector to use a proxy server
		+ Connections to target networks
		+ Outbound internet access
		
- Security group rules for the Connector
	+ Inbound rules
	+ Outbound rules
		+ Basic outbound rules
		+ Advanced outbound rules

## Installing the Connector software on an existing Linux host <a name="Installing-the-Connector-software-on-an-existing-Linux-host"></a>



## Planning your Cloud Volumes ONTAP configuration in Azure <a name="Planning-your-Cloud-Volumes-ONTAP-configuration-in-Azure"></a>

- Azure disk type
	+ What disk types are available in Azure? 
- Azure disk size 
	+ Managed Disks
	+ Page Blobs pricing
- Choosing a configuration that supports Flash Cache
	+ Learn more about Flash Cache
- Choosing a write speed
	+ Learn more about write speed

### Networking requirements for Cloud Volumes ONTAP in Azure

- Networking requirements for Cloud Volumes ONTAP in Azure 
	+ Outbound internet access for Cloud Volumes ONTAP
	+ Security groups
	+ Number of IP addresses
	+ Connection from Cloud Volumes ONTAP to Azure Blob storage for data tiering
	+ Connections to ONTAP systems in other networks

- Security group rules for Cloud Volumes ONTAP
	+ Inbound rules for single node systems
	+ Inbound rules for HA systems
	+ Outbound rules
		+ Basic outbound rules
		+ Advanced outbound rules
 
 Launching-Cloud-Volumes-ONTAP-in-Azure
 
 ## Launching Cloud Volumes ONTAP in Azure <a name="Launching-Cloud-Volumes-ONTAP-in-Azure"></a>

### Launching Cloud Volumes ONTAP in Azure

	+ Before you begin
	+ You should have a Connector that is associated with your workspace.
		+ You must be an Account Admin to create a Connector. When you create your first Cloud Volumes ONTAP working environment, Cloud Manager prompts you to create a Connector if you do not have one yet.
		+ You should always be prepared to leave the Connector running.
		+ You should have chosen a configuration and obtained Azure networking information from your administrator. For details, see Planning your Cloud Volumes ONTAP configuration.
		+ To deploy a BYOL system, you need the 20-digit serial number (license key) for each node.
	+ About this task
		+ When Cloud Manager creates a Cloud Volumes ONTAP system in Azure, it creates several Azure objects, such as a resource group, network interfaces, and storage accounts. You can review a summary of the resources at the end of the wizard.
		+ Potential for Data Loss
			+ Deploying Cloud Volumes ONTAP in an existing, shared resource group is not recommended due to the risk of data loss. While rollback is currently disabled by default when using the API to deploy into an existing resource group, deleting Cloud Volumes ONTAP will potentially delete other resources from that shared group.
			+ The best practice is to use a new, dedicated resource group for Cloud Volumes ONTAP. This is the default and only recommended option when deploying Cloud Volumes ONTAP in Azure from Cloud Manager.
			
#### Steps

		+ On the Canvas page, click Add Working Environment and follow the prompts.
		+ Choose a Location: Select Microsoft Azure and Cloud Volumes ONTAP Single Node or Cloud Volumes ONTAP High Availability.
		+ Details and Credentials: Optionally change the Azure credentials and subscription, specify a cluster name and resource group name, add tags if needed, and then specify credentials.
		+ Services: Keep the services enabled or disable the individual services that you do not want to use with Cloud Volumes ONTAP.
		+ Location & Connectivity: Select a location and security group and select the checkbox to confirm network connectivity between Cloud Manager and the target location.
		+ License and Support Site Account: Specify whether you want to use pay-as-you-go or BYOL, and then specify a NetApp Support Site account.
		+ Preconfigured Packages: Select one of the packages to quickly deploy a Cloud Volumes ONTAP system or click Create my own configuration.
		+ If you choose one of the packages, you only need to specify a volume and then review and approve the configuration.
		+ Licensing: Change the Cloud Volumes ONTAP version as needed, select a license, and select a virtual machine type.
			+ If your needs change after you launch the system, you can modify the license or virtual machine type later.
			+ If a newer Release Candidate, General Availability, or patch release is available for the selected version, then Cloud Manager updates the system to that version when creating the working environment. For example, the update occurs if you select Cloud Volumes ONTAP 9.6 RC1 and 9.6 GA is available. The update does not occur from one release to another—for example, from 9.6 to 9.7.
		+ Subscribe from the Azure Marketplace: Follow the steps if Cloud Manager could not enable programmatic deployments of Cloud Volumes ONTAP.
		+ Underlying Storage Resources: Choose settings for the initial aggregate: a disk type, a size for each disk, and whether data tiering to Blob storage should be enabled.
#### Note the following:

				+ The disk type is for the initial volume. You can choose a different disk type for subsequent volumes.
				+ The disk size is for all disks in the initial aggregate and for any additional aggregates that Cloud Manager creates when you use the simple provisioning option. You can create aggregates that use a different disk size by using the advanced allocation option.
				+ For help choosing a disk type and size, see Sizing your system in Azure.
				+ You can choose a specific volume tiering policy when you create or edit a volume.
				+ If you disable data tiering, you can enable it on subsequent aggregates.
				+ Learn more about data tiering.
		
#### Write Speed & WORM (single node systems only)

- Choose Normal or High write speed, and activate write once, read many (WORM) storage, if desired.
			+ Learn more about write speed.
			+ WORM cannot be enabled if data tiering was enabled.
			+ Learn more about WORM storage.
		+ Secure Communication to Storage & WORM (HA only): Choose whether to enable an HTTPS connection to Azure storage accounts, and activate write once, read many (WORM) storages, if desired.
			+ The HTTPS connection is from a Cloud Volumes ONTAP 9.7 HA pair to Azure storage accounts. Note that enabling this option can impact write performance. You cannot change the setting after you create the working environment.
			+ Learn more about WORM storage.
			
#### Create Volume

- Enter details for the new volume or click Skip
			+ CIFS Setup: If you chose the CIFS protocol, set up a CIFS server.
		+ Usage Profile, Disk Type, and Tiering Policy: Choose whether you want to enable storage efficiency features and change the volume tiering policy, if needed.
		+ Review & Approve: Review and confirm your selections.
			+ Review details about the configuration.
			+ Click More information to review details about support and the Azure resources that Cloud Manager will purchase.
			+ Select the I understand… check boxes.
			+ Click Go.
		
#### Result
		
			+ Cloud Manager deploys the Cloud Volumes ONTAP system. You can track the progress in the timeline.
			+ If you experience any issues deploying the Cloud Volumes ONTAP system, review the failure message. You can also select the working environment and click Re-create environment.
			+ For additional help, go to NetApp Cloud Volumes ONTAP Support.
#### After you finish

			+ If you provisioned a CIFS share, give users or groups permissions to the files and folders and verify that those users can access the share and create a file.
			+ If you want to apply quotas to volumes, use System Manager or the CLI.
			+ Quotas enable you to restrict or track the disk space and number of files used by a user, group, or qtree.

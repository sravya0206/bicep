<!-- Introduction --> 
# Hi there
<p> I am Sravya and I have around six years of Experience with Devops and Cloud. 
I will be presenting the Technical Task given to me for Deploying the Infrastructure on Azure using Bicep.
I have referred to Azure Official Documentation for Biceps. </p> 

# Overview of the Task
<p> In this Task I will be provisioning an Azure Keyvault, a Key and a Storage Account which will be encrypted with CMK by the key created in the KeyVault. These resources are Deployed using Bicep Modules and I also ensured the Dependencies between the Modules are intact. There is a Powershell script included where the necessary parameters are defined and the Main Bicep Template execution is added.  </p> 

# Modules

## KeyVault
This Bicep module is used to provision an Azure Key Vault with customizable parameters.

- ### **File Name**: `keyvault.bicep`

- ### **Parameters**:

 -  `mykeyvault` : This parameter represents the name of the Key Vault to be created. It is of type string.

 - `location`: This parameter represents the location of the resources. It is optional and defaults to the location of the resource group where the Key Vault is being created. The default value is obtained using the resourceGroup().location function.

- ### **Resources**:

 - `vault`: This is the Azure Key Vault resource being created. It is of type Microsoft.KeyVault/vaults@2021-11-01-preview, indicating the resource provider and API version.

 - `name`: Specifies the name of the Key Vault, which is provided as the value of the mykeyvault parameter.

 - `location`: Specifies the location of the Key Vault resource, which is provided as the value of the location parameter.

 - `properties`: This object contains various properties of the Key Vault:

   - `sku`: Defines the SKU (Stock Keeping Unit) configuration for the Key Vault. In this case, it specifies that the SKU is standard.

 - `tenantId`: Specifies the ID of the tenant associated with the subscription, which is obtained using the subscription().tenantId function.

 - `accessPolicies`: This array defines the access policies for the Key Vault. In this case, it is an empty array, meaning there are no access policies defined at creation time.

 - `enableRbacAuthorization`: Indicates whether RBAC (Role-Based Access Control) authorization is enabled for the Key Vault. It is set to true in this module.

 - `enableSoftDelete`: Specifies whether soft-delete functionality is enabled for the Key Vault. Soft-delete allows recovery of deleted Key Vault objects. It is set to true.

 - `softDeleteRetentionInDays`: Specifies the number of days that items are retained in the Key Vault's recycle bin before being permanently deleted. It is set to 90 days.

 - `enabledForDeployment`: Indicates whether the Key Vault is enabled for resource deployment. It is set to false.

 - `enabledForDiskEncryption`: Indicates whether the Key Vault is enabled for disk encryption. It is set to false.

 - `enabledForTemplateDeployment`: Indicates whether the Key Vault is enabled for template deployment. It is set to false.

- ### **Output**:

 - `keyVaultResourceId`: This output variable exposes the resource ID (id property) of the Key Vault created by the module. It allows GenerateKey module to reference the Key Vault resource ID.

## GenerateKey
This Bicep module aims to provision a cryptographic key within an Azure Key Vault

- ### **param keyVaultResourceId string:**

  This line declares a parameter named keyVaultResourceId of type string. This parameter will be used to specify the resource ID of the Azure Key Vault where the key will be created.

- ### **resource key 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview':**

  This line defines a new resource named key.
  'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' specifies the resource type and API version of the Key Vault key resource.
  
  - `parent: keyVaultResourceId`:
     The parent property specifies the parent resource for the key.
     In this case, keyVaultResourceId is used as the parent resource ID, which refers to the Azure Key Vault where the key will be created.
  - `name: 'MyKey'`:
     This line specifies the name of the key to be created within the Azure Key Vault.
     The key will be named 'MyKey'.
  - `properties`:
     This section defines properties for the key being created.
    - `keySize: 2048`:
     Specifies the size of the cryptographic key in bits. In this case, the key size is set to 2048 bits.
    - `kty: 'RSA'`:
     Specifies the key type. 'RSA' indicates that the key will use the RSA encryption algorithm.
    - `keyOps`:
     Specifies the cryptographic operations that the key can perform. The operations listed include 'encrypt', 'decrypt', 'sign', and 'verify'. This means that the key can be used for encryption, decryption, signing, and verification operations.

## StorageAccount
This Bicep module defines an Azure Storage Account resource with CMK encryption by the key created in the
KeyVault
 - ### Parameters:

  - `mystorageaccount`: Parameter representing the name of the storage account.

  - `location`: Parameter representing the location of the storage account. It defaults to the location     of the resource group where the storage account will be deployed.

  - `keyVaultResourceId`: Parameter representing the resource ID of the Azure Key Vault where the    encryption key is stored.

  - #### **Resource Definition**: ####

    - `storageAccount`: Defines a Microsoft.Storage/storageAccounts resource with the specified properties.

    - `name`: Specifies the name of the storage account (provided by the mystorageaccount parameter).

    - `location`: Specifies the location of the storage account (provided by the location parameter).

    - `sku`: Specifies the SKU (Standard_LRS) for the storage account.

    - `kind`: Specifies the kind of storage account (StorageV2).

    - `properties.encryption`: Defines encryption settings for the storage account.

      - `keySource`: Specifies the source of the encryption key, which is set to 'Microsoft.Keyvault'.

      - `keyvaultproperties`: Defines properties related to the Azure Key Vault where the encryption key  is stored.
        - `keyname`: Specifies the name of the key stored in the Key Vault.

        - `keyvaulturi`: Specifies the URI of the Azure Key Vault (provided by the keyVaultResourceId parameter).

  - ### Output: ###

    - `storageAccountId`: Outputs the resource ID of the created storage account.

# How to Deploy

## Main Bicep Template:

### Description

- **File Name**: `main.bicep`
- **Purpose**: This main.bicep file calls the defined modules and also ensure that modules are instantiated in the correct order, and that outputs from one module are used as inputs to another where necessary.
- The GenerateKey module depends on the keyVault module. By specifying dependsOn: [ keyVault ], you ensure that the generateKey module is only executed after the keyVault module has completed its deployment. This is important because the generateKey module requires the output keyVaultResourceId from the keyVault module.

- The StorageAccount module depends on GenerateKey module. By specifying dependsOn: [ GeerateKey ], you ensure that the StorageAccount module is only executed after the GenerateKey module has completed its deployment. This is important because the StorageAccount module requires the output KeyName from the keyVault module.

## PowerShell Script:

### Description

- **File Name**: `main.ps1`
- **Purpose**: This PowerShell script is used to deploy an Azure Bicep template to provision resources, focusing on Key Vault creation.

### Parameters

- **`keyVaultName`**: Name of the Key Vault to be created.
- **`location`**: Azure region where the Key Vault will be deployed.
- **`keyVaultResourceGroupName`**: Resource group name where the Key Vault will be created.
- **`keyVaultDeploymentName`**: Name of the deployment for the Key Vault.

### Script Flow

1. **Login to Azure (if not already logged in)**: Connects to Azure using `Connect-AzAccount -Tenant 'xxxx-xxxx-xxxx-xxxx' -SubscriptionId 'yyyy-yyyy-yyyy-yyyy'` cmdlet.
2. **Set Deployment Scope**: Sets the deployment scope to the Key Vault resource group using `Set-AzContext`.
3. **Get Current Directory**: Retrieves the current directory where the script resides.
4. **Preview Changes using WhatIf**: Previews the deployment changes using `New-AzResourceGroupDeployment` with the `-WhatIf` flag.
5. **Confirm Deployment**: Prompts the user to confirm whether to proceed with the deployment.
6. **Execute Deployment**: If confirmed, executes the deployment using `New-AzResourceGroupDeployment`.

### Example

```powershell
.\main.ps1 -keyVaultName "keyvault" -location "East US" -keyVaultResourceGroupName "myResourceGroup" -keyVaultDeploymentName "KeyVaultDeployment"


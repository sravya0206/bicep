@description('The name of the storage account')
param mystorageaccount string
@description('The storage account location.')
param location string = resourceGroup().location

param keyVaultResourceId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: mystorageaccount
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      keySource: 'Microsoft.Keyvault'
      keyvaultproperties: {
        keyname: 'MyKey' 
        keyvaulturi: keyVaultResourceId
      }
    }
  }
}

output storageAccountId string = storageAccount.id

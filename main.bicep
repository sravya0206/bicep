param keyVaultName string
param storageAccountName string
param location string

module keyVault './KeyVault/keyvault.bicep' = {
  name: 'keyVault'
  params: {
    keyVaultName: mykeyvault
    location: location
  }
}

module generateKey './GenerateKey/generatekey.bicep' = {
  name: 'generateKey'
  params: {
    keyVaultResourceId: keyVault.outputs.keyVaultResourceId
  }
  dependsOn: [
    keyVault
  ]
}

module storageAccount './StorageAccount/storageaccount.bicep' = {
  name: 'storageAccount'
  params: {
    storageAccountName: mystorageaccount
    location: location
  }
  dependsOn: [
    generateKey
  ]
}

output keyVaultResourceId string = keyVault.outputs.keyVaultResourceId
output storageAccountId string = storageAccount.outputs.storageAccountId

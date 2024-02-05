@description('The name of the key vault to be created.')
param mykeyvault string

@description('The location of the resources')
param location string = resourceGroup().location

resource vault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: mykeyvault
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
  }
}

output keyVaultResourceId string = vault.id

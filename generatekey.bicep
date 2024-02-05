param keyVaultResourceId string

resource key 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' = {
  parent: keyVaultResourceId
  name: 'MyKey'
  properties: {
    keySize: 2048
    kty: 'RSA'
    keyOps: [
      'encrypt'
      'decrypt'
      'sign'
      'verify'
    ]
  }
}

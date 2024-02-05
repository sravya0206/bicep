param (
    [Parameter(Mandatory = $true)]
    [string] $keyVaultName,
    
    [Parameter(Mandatory = $true)]
    [string] $location,
    
    [Parameter(Mandatory = $true)]
    [string] $keyVaultResourceGroupName,
    
    [Parameter(Mandatory = $true)]
    [string] $keyVaultDeploymentName
)

# Login to Azure (if not already logged in)
Connect-AzAccount -Tenant 'xxxx-xxxx-xxxx-xxxx' -SubscriptionId 'yyyy-yyyy-yyyy-yyyy'

# Set the deployment scope to the Key Vault resource group
Set-AzContext -SubscriptionId $subscriptionId -ResourceGroupName $keyVaultResourceGroupName

# Get the current directory
$currentDirectory = $PSScriptRoot
$bicepFile = "$currentDirectory\main.bicep"

# Execute WhatIf to preview changes
Write-Host "Previewing changes using WhatIf..."
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $bicepFile -TemplateParameterObject $parameters -WhatIf

# Confirm deployment
$confirm = Read-Host "Do you want to proceed with the deployment? (Y/N)"

if ($confirm -eq "Y" -or $confirm -eq "y") {
    # Execute deployment without WhatIf
    Write-Host "Executing deployment..."
    New-AzResourceGroupDeployment `
    -Name $keyVaultDeploymentName `
    -ResourceGroupName $keyVaultResourceGroupName `
    -TemplateFile $bicepFile `
    -TemplateParameterObject @{
        'keyVaultName' = $keyVaultName
        'location' = $location
    }
} else {
    Write-Host "Deployment canceled."
}



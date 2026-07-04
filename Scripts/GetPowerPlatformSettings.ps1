Write-Host "Starting Power Platform export job..."
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outputFolder = "/app/Output-$timestamp"
New-Item -ItemType Directory -Force -Path $outputFolder | Out-Null
New-Item -ItemType Directory -Force -Path "$outputFolder/env-settings" | Out-Null

$storageAccountName = $env:STORAGE_ACCOUNT_NAME
$containerName = $env:STORAGE_CONTAINER_NAME

if ([string]::IsNullOrEmpty($storageAccountName)) {
    throw "Missing environment variable STORAGE_ACCOUNT_NAME"
}

if ([string]::IsNullOrEmpty($containerName)) {
    throw "Missing environment variable STORAGE_CONTAINER_NAME"
}

#Connect Using Power Platform CLI
if($env:IDENTITY_ENDPOINT) {
    
    #Azure identity authentication
    Write-Host "Authenticating Azure CLI using Managed Identity..."
    az login --identity

    #Managed identity authentication
    Write-Host "Authenticating Power Platform CLI using Managed Identity..."
    pac auth create --managedIdentity
}
else {
    #Basic authentication
    pac auth create --deviceCode
}

#Get Tenant-Level Settings
Write-Host "Getting tenant level settings"
pac admin list-tenant-settings --settings-file "$outputFolder/tenant-settings.json"

#Get List of Environments
$environments = pac admin list --json | ConvertFrom-Json
$environments | ConvertTo-Json -Depth 10 | Out-File "$outputFolder/environments.json" 

# For each environment get the settings pac env list-settings
foreach ($ppenv in $environments) {
    #Self-elevate to System Administrator role
    #pac admin self-elevate --environment $ppenv.EnvironmentId

    #Get settings
    pac env list-settings --environment $ppenv.EnvironmentUrl --json | Out-File "$outputFolder/env-settings/$($ppenv.DisplayName).json"
}

#Get list of environment groups
pac admin list-groups --json | Out-File "$outputFolder/environment-groups.json" 

Write-Host "Uploading result files to Azure Blob Storage..."

az storage blob upload-batch `
    --account-name $storageAccountName `
    --destination "$containerName/$timestamp" `
    --source $outputFolder `
    --auth-mode login


#TBD: Get Advanced Connector Policies, currently there's no method through Power Platform CLI
    # For each DLP policy Show Details

Write-Host "Hello world"
Write-Host "Authenticating Azure CLI using Managed Identity..."
az login --identity

Write-Host "Authenticating Power Platform CLI using Managed Identity..."
    pac auth create --managedIdentity
    pac auth who

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $outputFolder = "/app/Output-$timestamp"

    New-Item -ItemType Directory -Path $outputFolder

    pac admin list --json | Out-File "$outputFolder/environments.json" 
    
    Write-Host "Uploading result files to Azure Blob Storage..."

az storage blob upload-batch `
    --account-name "powerplatformsettings" `
    --destination "settings-export/$timestamp" `
    --source $outputFolder `
    --auth-mode login
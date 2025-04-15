# Connect to Azure
Connect-AzAccount

Write-Host "`n=== Azure App Services Inventory with Backup Status (REST API) ===`n"

# Initialize counters
$totalAppServices   = 0
$totalBackupEnabled = 0
$allAppServices     = @()

# Get all subscriptions
$subscriptionsUri = "https://management.azure.com/subscriptions?api-version=2020-01-01"
$globalToken = (Get-AzAccessToken).Token  # Used only to get list of subscriptions
$globalHeaders = @{
    'Authorization' = "Bearer $globalToken"
    'Content-Type'  = 'application/json'
}
$subscriptions = (Invoke-RestMethod -Uri $subscriptionsUri -Headers $globalHeaders).value

foreach ($sub in $subscriptions) {
    # Set context and refresh token per subscription
    Set-AzContext -SubscriptionId $sub.subscriptionId | Out-Null
    $token = (Get-AzAccessToken).Token
    $headers = @{
        'Authorization' = "Bearer $token"
        'Content-Type'  = 'application/json'
    }

    Write-Host "`n  Subscription: $($sub.displayName)"
    Write-Host "----------------------------------------"

    # Get resource groups
    $rgUri = "https://management.azure.com/subscriptions/$($sub.subscriptionId)/resourcegroups?api-version=2021-04-01"
    $resourceGroups = (Invoke-RestMethod -Uri $rgUri -Headers $headers).value

    foreach ($rg in $resourceGroups) {
        Write-Host "    Resource Group: $($rg.name)"

        # Get web apps
        $webAppsUri = "https://management.azure.com/subscriptions/$($sub.subscriptionId)/resourceGroups/$($rg.name)/providers/Microsoft.Web/sites?api-version=2022-03-01"
        $webApps = (Invoke-RestMethod -Uri $webAppsUri -Headers $headers).value
        $count = if ($webApps) { $webApps.Count } else { 0 }
        $totalAppServices += $count

        if ($count -gt 0) {
            Write-Host "      App Services ($count):"

            foreach ($webApp in $webApps) {
                $hasBackup = $false
                $backupSettings = $null

                try {
                    $backupUri = "https://management.azure.com/subscriptions/$($sub.subscriptionId)/resourceGroups/$($rg.name)/providers/Microsoft.Web/sites/$($webApp.name)/config/backup?api-version=2022-03-01"
                    $backupConfig = Invoke-RestMethod -Uri $backupUri -Headers $headers -Method "GET"

                    if ($backupConfig.properties -and $backupConfig.properties.enabled -eq $true) {
                        $hasBackup = $true
                        $totalBackupEnabled++
                        $backupSettings = $backupConfig.properties
                        Write-Host "        - $($webApp.name): Backup ENABLED"
                    } else {
                        Write-Host "        - $($webApp.name): Backup DISABLED"
                    }
                }
                catch {
                    Write-Host "        - $($webApp.name): Error checking backup config - $($_.Exception.Message)"
                }

                # Store info
                $appInfo = [PSCustomObject]@{
                    Name                = $webApp.name
                    Location            = $webApp.location
                    ResourceGroup       = $rg.name
                    Subscription        = $sub.displayName
                    HasBackup           = $hasBackup
                    BackupFrequency     = if ($hasBackup) { $backupSettings.backupSchedule.frequencyInterval } else { "None" }
                    BackupRetentionDays = if ($hasBackup) { $backupSettings.retentionPeriodInDays } else { "N/A" }
                }

                $allAppServices += $appInfo
            }
        }
    }
}

# Final Summary
Write-Host "`n=== Summary ==="
Write-Host "Total App Services: $totalAppServices"
Write-Host "With backup enabled: $totalBackupEnabled"
Write-Host "Without backup: $($totalAppServices - $totalBackupEnabled)"

# Output as table
Write-Host "`nDetailed List of App Services:"
Write-Host "----------------------------------------"
$allAppServices | Format-Table -AutoSize

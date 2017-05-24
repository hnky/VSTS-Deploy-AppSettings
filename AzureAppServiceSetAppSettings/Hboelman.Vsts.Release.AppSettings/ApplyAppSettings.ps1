[CmdletBinding()]
param(
    [String] [Parameter(Mandatory = $true)]
    $ConnectedServiceName,

    [String] [Parameter(Mandatory = $true)]
    $WebAppName,

    [String] [Parameter(Mandatory = $true)]
    $ResourceGroupName,

    [String] [Parameter(Mandatory = $true)]
    $AppSettings
)

# For more information on the VSTS Task SDK:
# https://github.com/Microsoft/vsts-task-lib

import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

Write-Host("=== START ===")
Write-Host ("Webapp: " + $WebAppName)
Write-Host ("Resourcegroup: " + $ResourceGroupName)
Write-Host ("Appsettings: " + $AppSettings)

$lines = $AppSettings.Replace("`r","").Split()
Write-Host ("Lines found: " + $lines.Count)

$activeAppSettings = Get-AzureRMWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName 
$appSettingList = $activeAppSettings.SiteConfig.AppSettings

$hash = @{}

foreach ($kvp in $appSettingList) {
    $hash[$kvp.Name] = $kvp.Value.ToString()
    Write-Host ("Found - Key: " + $kvp.Name + " Value: " + $kvp.Value)
}

foreach ($keyValue in $lines) {
    $key,$val,$leftover = $keyValue.Split("'")
    $hash[$key.ToString().Replace("=","").Trim()] = $val.ToString()
    Write-Host ("Adding - Key: " + $key.Replace("=","")  + " Value: " + $val)
}

Set-AzureRMWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -AppSettings $hash
Write-Host("=== DONE ===")

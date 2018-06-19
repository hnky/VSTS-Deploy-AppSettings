[CmdletBinding()]
param(
    [String] [Parameter(Mandatory = $true)]
    $ConnectedServiceName,

    [String] [Parameter(Mandatory = $true)]
    $WebAppName,
    
    [String] [Parameter(Mandatory = $true)]
    $ResourceGroupName,

    [String] [Parameter(Mandatory = $false)]
    $Slot = "",

    [String] [Parameter(Mandatory = $false)]
    $InputType,

    [String] [Parameter(Mandatory = $true, ParameterSetName = "Multiline")]
    $AppSettings,

    [String] [Parameter(Mandatory = $true, ParameterSetName = "Filepath")]
    $AppSettingsFilePath
)

# For more information on the VSTS Task SDK:
# https://github.com/Microsoft/vsts-task-lib

import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

If ($Slot -eq "") {
    $Slot = "production"
}

Write-Host ("=== START ===")
Write-Host ("Input type: " + $InputType)
Write-Host ("Webapp: " + $WebAppName)
Write-Host ("Slot: " + $Slot)
Write-Host ("Appsettings: " + $AppSettings)
Write-Host ("AppSettingsFilePath: " + $AppSettingsFilePath)

$seperator = [Environment]::NewLine
$splitOption = [System.StringSplitOptions]::RemoveEmptyEntries

$lines = $AppSettings.Split($seperator, $splitOption)
Write-Host ("Lines found: " + $lines.Count)

$webApp = Get-AzureRMWebAppSlot -Name $WebAppName -ResourceGroupName $ResourceGroupName -Slot $Slot
$appSettingList = $webApp.SiteConfig.AppSettings

$hash = @{}

foreach ($kvp in $appSettingList) {
    $hash[$kvp.Name] = $kvp.Value.ToString()
    Write-Host ("Found - Key: " + $kvp.Name + " Value: " + $kvp.Value)
}

foreach ($keyValue in $lines) {
    $key, $val = $keyValue.Split("'", $splitOption)
    $hash[$key.ToString().Replace("=", "").Trim()] = $val
    Write-Host ("Adding - Key: " + $key.Replace("=", "") + " Value: " + $val)
}

Set-AzureRMWebAppSlot -Name $WebAppName -ResourceGroupName $ResourceGroupName -Slot $Slot -AppSettings $hash

Write-Host("=== DONE ===")

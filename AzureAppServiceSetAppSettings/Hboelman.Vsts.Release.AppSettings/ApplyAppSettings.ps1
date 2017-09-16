[CmdletBinding()]
param(
    [String] [Parameter(Mandatory = $true)]
    $ConnectedServiceName,

    [String] [Parameter(Mandatory = $true)]
    $WebAppName,
    
    [String] [Parameter(Mandatory = $true)]
    $ResourceGroupName,

    [String]
    $AppSettings = "",

    [String]
    $ConnectionStrings = ""
)

# For more information on the VSTS Task SDK:
# https://github.com/Microsoft/vsts-task-lib

import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

Write-Host("=== START ===")
Write-Host ("Webapp: " + $WebAppName)
Write-Host ("Appsettings: " + $AppSettings)
Write-Host ("Connectionstrings: " + $ConnectionStrings)

$seperator = [Environment]::NewLine
$splitOption = [System.StringSplitOptions]::RemoveEmptyEntries

$appSettingsLines = $AppSettings.Split($seperator, $splitOption)
$connStringLines = $ConnectionStrings.Split($seperator, $splitOption)
$lines = $appSettingsLines.Length + $connStringLines.Length
Write-Host ("Lines found: " + $lines.Count)

$webApp = Get-AzureRMWebApp -Name $WebAppName -ResourceGroupName $ResourceGroupName
$appSettingList = $WebApp.SiteConfig.AppSettings
$connStringList = $WebApp.SiteConfig.Connectionstrings

$appSettingHash = @{}

foreach ($kvp in $appSettingList) {
    $appSettingHash[$kvp.Name] = $kvp.Value.ToString()
    Write-Host ("Found - Key: " + $kvp.Name + " Value: " + $kvp.Value)
}

foreach ($keyValue in $appSettingsLines) {
    $key,$val = $keyValue.Split("'", $splitOption)
    $appSettingHash[$key.ToString().Replace("=","").Trim()] = $val
    Write-Host ("Adding - Key: " + $key.Replace("=","")  + " Value: " + $val)
}

$connStringHash = @{}

foreach ($kvp in $connStringList) {
    $connStringHash[$kvp.Name] = @{"Value"=$kvp.ConnectionString.ToString();"Type"=$kvp.Type.ToString()} 
    Write-Host ("Found - Key: " + $kvp.Name + " Value: " + $kvp.ConnectionString)
}

foreach ($keyValue in $connStringLines) {
    $key,$val,$type = $keyValue.Split("'", $splitOption)
    $connStringHash[$key.ToString().Replace("=","").Trim()] = @{"Value"=$val;"Type"=$type}
    Write-Host ("Adding - Key: " + $key.Replace("=","")  + " Value: " + $val + " Type" + $type)
}

Set-AzureRMWebApp -Name $WebAppName -ResourceGroupName $ResourceGroupName -AppSettings $appSettingHash -ConnectionStrings $connStringHash
Write-Host("=== DONE ===")

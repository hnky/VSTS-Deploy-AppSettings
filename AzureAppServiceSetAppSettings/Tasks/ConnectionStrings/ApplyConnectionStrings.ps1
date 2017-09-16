[CmdletBinding()]
param(
    [String] [Parameter(Mandatory = $true)]
    $ConnectedServiceName,

    [String] [Parameter(Mandatory = $true)]
    $WebAppName,
    
    [String] [Parameter(Mandatory = $true)]
    $ResourceGroupName,
    
    [String] [Parameter(Mandatory = $true)]
    $ConnectionStrings
)

# For more information on the VSTS Task SDK:
# https://github.com/Microsoft/vsts-task-lib

import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

Write-Host("=== START ===")
Write-Host ("Webapp: " + $WebAppName)
Write-Host ("Connectionstrings: " + $ConnectionStrings)

$seperator = [Environment]::NewLine
$splitOption = [System.StringSplitOptions]::RemoveEmptyEntries

$lines = $ConnectionStrings.Split($seperator, $splitOption)
Write-Host ("Lines found: " + $lines.Count)

$webApp = Get-AzureRMWebApp -Name $WebAppName -ResourceGroupName $ResourceGroupName
$connectionStringList = $WebApp.SiteConfig.Connectionstrings

$hash = @{}

foreach ($kvp in $connectionStringList) {
    $hash[$kvp.Name] = @{"Value"=$kvp.ConnectionString.ToString();"Type"=$kvp.Type.ToString()} 
    Write-Host ("Found - Key: " + $kvp.Name + " Value: " + $kvp.ConnectionString)
}

foreach ($keyValue in $lines) {
    $key,$val,$type = $keyValue.Split("'", $splitOption)
    $hash[$key.ToString().Replace("=","").Trim()] = @{"Value"=$val;"Type"=$type}
    Write-Host ("Adding - Key: " + $key.Replace("=","")  + " Value: " + $val + " Type" + $type)
}

Set-AzureRMWebApp -Name $WebAppName -ResourceGroupName $ResourceGroupName -ConnectionStrings $hash
Write-Host("=== DONE ===")

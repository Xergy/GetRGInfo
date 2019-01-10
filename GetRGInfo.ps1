<#
    .SYNOPSIS
        Gathers selected cross subscription Azure configuration details by resource group, and outputs to csv, html, and zip

    .NOTES
        GetRGInfo allows a user to pick specific Subs/RGs in out-gridview 
        and export info to CSV and html report.

        It is designed to be easily edited to for any specific purpose.

        It writes temp data to C:\temp. It also zips up the final results.

    .EXAMPLE
        .\GetRGInfo.ps1

#>

$ScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition) 
Set-Location $ScriptDir

#if not logged in to Azure, start login
if ((Get-AzureRmContext).Account -eq $Null) {
Connect-AzureRmAccount -Environment AzureUSGovernment}

#region Build Config File

$subs = Get-AzureRmSubscription | Out-GridView -OutputMode Multiple -Title "Select Subscriptions"
$RGs = @()

foreach ( $sub in $subs )
{

    Select-AzureRmSubscription -SubscriptionName $sub.Name
    
    $SubRGs = Get-AzureRmResourceGroup |  
        Add-Member -MemberType NoteProperty –Name Subscription –Value $sub.Name -PassThru |
        Add-Member -MemberType NoteProperty –Name SubscriptionId –Value $sub.Id -PassThru |
        Out-GridView -OutputMode Multiple -Title "Select Resource Groups"

    foreach ( $SubRG in $SubRGs )
    {

    $RGs = $RGS + $SubRg

    }
}

$Rgs | Export-Csv -NoTypeInformation -Path "config.csv"


#endregion


#region Gather Info

$RGs = Import-Csv -Path "config.csv"

$VMs = @()
$StorageAccounts = @()
$Disks = @() 
$Vnets = @()
$NetworkInterfaces = @()
$NSGs = @()
$AutoAccounts = @()
$LogAnalystics = @()
$KeyVaults = @()
$RecoveryServicesVaults = @()
$BackupItemSummary = @()
$AVSets = @()

foreach ( $RG in $RGs )
{
    
    Write-Host "Gathering Info for $($RG.ResourceGroupName)" -ForegroundColor Cyan
    
    Select-AzureRmSubscription -SubscriptionName $RG.Subscription | Out-Null
 
    $VMs +=  Get-AzureRmVM -ResourceGroupName $RG.ResourceGroupName |
        Add-Member -MemberType NoteProperty –Name Subscription –Value $RG.Subscription -PassThru |
        Add-Member -MemberType NoteProperty –Name SubscriptionId –Value $RG.SubscriptionID -PassThru |
        foreach-object { $_ | Add-Member -MemberType NoteProperty –Name Size –Value ($_.HardwareProfile.Vmsize) -PassThru} |
        foreach-object { $_ | Add-Member -MemberType NoteProperty –Name OsType –Value ($_.StorageProfile.OsDisk.OsType) -PassThru} |
        foreach-object { $_ | Add-Member -MemberType NoteProperty –Name NicCount –Value ($_.NetworkProfile.NetworkInterfaces.Count) -PassThru} |
        foreach-object { $_ | Add-Member -MemberType NoteProperty –Name NicCountCap –Value ($_.NetworkProfile.NetworkInterfaces.Capacity) -PassThru} |
        foreach-object { $AvailabilitySet = If($_.AvailabilitySetReference){$_.AvailabilitySetReference.Id.Split("/")[8]}Else{$Null} ;
            $_ | Add-Member -MemberType NoteProperty –Name AvailabilitySet –Value ($AvailabilitySet) -PassThru} |        
        forEach-Object { $VMStatus = Get-AzureRMVM -Name $_.Name -ResourceGroupName $RG.ResourceGroupName -Status ;
            $_ | Add-Member -MemberType NoteProperty –Name FaultDomain –Value ($VMStatus.PlatformFaultDomain) -PassThru |
                Add-Member -MemberType NoteProperty –Name UpdateDomain –Value ($VMStatus.PlatformUpdateDomain) -PassThru} 
    
    $StorageAccounts += $RG | 
        get-AzureRmStorageAccount |
        Add-Member -MemberType NoteProperty –Name Subscription –Value $RG.Subscription -PassThru |
        Add-Member -MemberType NoteProperty –Name SubscriptionId –Value $RG.SubscriptionID -PassThru 

    $Disks += $RG |
        Get-AzureRmDisk |
        Add-Member -MemberType NoteProperty –Name Subscription –Value $RG.Subscription -PassThru |
        Add-Member -MemberType NoteProperty –Name SubscriptionId –Value $RG.SubscriptionID -PassThru 
         
    $Vnets +=  $RG | 
        Get-AzureRmVirtualNetwork |
        Add-Member -MemberType NoteProperty –Name Subscription –Value $RG.Subscription -PassThru |
        Add-Member -MemberType NoteProperty –Name SubscriptionId –Value $RG.SubscriptionID -PassThru 

    $NetworkInterfaces +=  $RG |
        Get-AzureRmNetworkInterface |
        Add-Member -MemberType NoteProperty –Name Subscription –Value $RG.Subscription -PassThru |
        Add-Member -MemberType NoteProperty –Name SubscriptionId –Value $RG.SubscriptionID -PassThru |
        foreach-object { $_ | Add-Member -MemberType NoteProperty –Name Owner –Value ($_.VirtualMachine.Id) -PassThru} |
        foreach-object { $_ | Add-Member -MemberType NoteProperty –Name PrivateIp –Value ($_.IpConfigurations[0].PrivateIpAddress) -PassThru} |
        foreach-object { $_ | Add-Member -MemberType NoteProperty –Name NSG –Value ($_.NetworkSecurityGroup.id) -PassThru} 


    $NSGs += $RG |
        Get-AzureRmNetworkSecurityGroup         |
        Add-Member -MemberType NoteProperty –Name Subscription –Value $RG.Subscription -PassThru |
        Add-Member -MemberType NoteProperty –Name SubscriptionId –Value $RG.SubscriptionID -PassThru 

    $AutoAccounts += $RG | 
        Get-AzureRmAutomationAccount |
        Add-Member -MemberType NoteProperty –Name Subscription –Value $RG.Subscription -PassThru #|
        #Add-Member -MemberType NoteProperty –Name SubscriptionId –Value $RG.SubscriptionID -PassThru 
        
    $LogAnalystics += $RG |
        Get-AzureRmOperationalInsightsWorkspace |
        Add-Member -MemberType NoteProperty –Name Subscription –Value $RG.Subscription -PassThru |
        Add-Member -MemberType NoteProperty –Name SubscriptionId –Value $RG.SubscriptionID -PassThru 

    $KeyVaults += Get-AzureRmKeyVault -ResourceGroupName ($RG).ResourceGroupName |
        Add-Member -MemberType NoteProperty –Name Subscription –Value $RG.Subscription -PassThru |
        Add-Member -MemberType NoteProperty –Name SubscriptionId –Value $RG.SubscriptionID -PassThru

<#
    $RecoveryServicesVaults += Get-AzureRmRecoveryServicesVault -ResourceGroupName ($RG).ResourceGroupName |
        Add-Member -MemberType NoteProperty –Name Subscription –Value $RG.Subscription -PassThru | 
        ForEach-Object { $_ | Add-Member -MemberType NoteProperty –Name BackupStorageRedundancy –Value ((Get-AzureRmRecoveryServicesBackupProperty -Vault $_ ).BackupStorageRedundancy) -PassThru }    

    #BackupItems Summary

        foreach ($recoveryservicesvault in $recoveryservicesvaults) {
            #write-host $recoveryservicesvault.name
            Get-AzureRmRecoveryServicesVault -Name $recoveryservicesvault.Name | Set-AzureRmRecoveryServicesVaultContext   

            $containers = Get-AzureRmRecoveryServicesBackupContainer -ContainerType azurevm


            foreach ($container in $containers) {
                #write-host $container.name

                $BackupItem = Get-AzureRmRecoveryServicesBackupItem -Container $container -WorkloadType "AzureVM"

                $BackupItem = $BackupItem |
                Add-Member -MemberType NoteProperty –Name FriendlyName –Value $Container.FriendlyName -PassThru |        
                Add-Member -MemberType NoteProperty –Name ResourceGroupName –Value $Container.ResourceGroupName -PassThru |
                Add-Member -MemberType NoteProperty –Name RecoveryServicesVault –Value $RecoveryServicesVault.Name -PassThru 
 
                $BackupItemSummary += $backupItem

            } 
        }
#>

    $AVSets +=  $RG | Get-AzureRmAvailabilitySet |
    Add-Member -MemberType NoteProperty –Name Subscription –Value $RG.Subscription -PassThru |
    Add-Member -MemberType NoteProperty –Name SubscriptionId –Value $RG.SubscriptionID -PassThru | 
    ForEach-Object {
        $AvailVMSizesD =($_ | Select-Object -Property ResourceGroupName, @{N='AvailabilitySetName';E={$_.Name}} | Get-AzureRmVMSize | ForEach-Object { $_.Name} | Where-Object {$_ -like "Standard_D*" -and $_ -notlike "*promo*" -and $_ -notlike "*v*"} | ForEach-Object {$_.Replace("Standard_","") } | Sort-Object ) -join " " ;
        $AvailVMSizesDv2 =($_ | Select-Object -Property ResourceGroupName, @{N='AvailabilitySetName';E={$_.Name}} | Get-AzureRmVMSize | ForEach-Object { $_.Name} | Where-Object {$_ -like "Standard_D*" -and $_ -notlike "*promo*" -and $_ -like "*v2*"} | ForEach-Object {$_.Replace("Standard_","") } | Sort-Object ) -join " " ;
        $AvailVMSizesDv3 =($_ | Select-Object -Property ResourceGroupName, @{N='AvailabilitySetName';E={$_.Name}} | Get-AzureRmVMSize | ForEach-Object { $_.Name} | Where-Object {$_ -like "Standard_D*" -and $_ -notlike "*promo*" -and $_ -like "*v3*"} | ForEach-Object {$_.Replace("Standard_","") } | Sort-Object ) -join " " ;
        $AvailVMSizesA =($_ | Select-Object -Property ResourceGroupName, @{N='AvailabilitySetName';E={$_.Name}} | Get-AzureRmVMSize | ForEach-Object { $_.Name} | Where-Object {$_ -like "Standard_A*" -and $_ -notlike "*promo*"} | ForEach-Object {$_.Replace("Standard_","") } | Sort-Object ) -join " " ;
        $_ | Add-Member -MemberType NoteProperty –Name AvailVMSizesD –Value $AvailVMSizesD -PassThru |
        Add-Member -MemberType NoteProperty –Name AvailVMSizesDv2 –Value $AvailVMSizesDv2 -PassThru |
        Add-Member -MemberType NoteProperty –Name AvailVMSizesDv3 –Value $AvailVMSizesDv3 -PassThru |
        Add-Member -MemberType NoteProperty –Name AvailVMSizesA –Value $AvailVMSizesA -PassThru
    }

}

#endregion


#region Filter and Sort Gathered Info

$FilteredRGs = $RGs  | Select-Object -Property ResourceGroupName,Subscription,SubscriptionId,Location

$VMs = $VMs | 
    Select-Object -Property Name,Subscription,ResourceGroupName,Location,OSType,Size,LicenseType,NicCount,NicCountCap,AvailabilitySet,FaultDomain,UpdateDomain |
    Sort-Object Subscription,ResourceGroupName,Name

$StorageAccounts = $StorageAccounts  | 
    Select-Object -Property StorageAccountName,Subscription,ResourceGroupName,Location |
    Sort-Object Subscription,ResourceGroupName,StorageAccountName

$Disks = $Disks | 
    Select-Object -Property Name,Subscription,ResourceGroupName,Location,OsType,DiskSizeGB |
    Sort-Object Subscription,ResourceGroupName,Name

$Vnets =  $Vnets | 
    Select-Object -Property Name,Subscription,ResourceGroupName,Location |
    Sort-Object Subscription,ResourceGroupName,Name

$NetworkInterfaces =  $NetworkInterfaces | 
    Select-Object -Property Name,Subscription,ResourceGroupName,Location,Owner,PrivateIp,Primary,NSG |
    Sort-Object Subscription,ResourceGroupName,Name

$NSGs = $NSGs | 
    Select-Object -Property Name,Subscription,ResourceGroupName,Location |
    Sort-Object Subscription,ResourceGroupName,Name

$AutoAccounts = $AutoAccounts | 
    Select-Object -Property AutomationAccountName,Subscription,ResourceGroupName,Location |
    Sort-Object Subscription,ResourceGroupName,AutomationAccountName

$LogAnalystics = $LogAnalystics  | 
    Select-Object -Property Name,Subscription,ResourceGroupName,Location |
    Sort-Object Subscription,ResourceGroupName,Name

$KeyVaults = $KeyVaults | 
    Select-Object -Property VaultName,Subscription,ResourceGroupName,Location |
    Sort-Object Subscription,ResourceGroupName,VaultName

<#
$RecoveryServicesVaults = $RecoveryServicesVaults |
    Select-Object -Property Name,Subscription,ResourceGroupName,Location,BackupStorageRedundancy  |
    Sort-Object Subscription,ResourceGroupName,Name

$BackupItemSummary = $BackupItemSummary |
    Select-Object -Property FriendlyName,RecoveryServicesVault,ProtectionStatus,ProtectionState,LastBackupStatus,LastBackupTime,ProtectionPolicyName,LatestRecoveryPoint,ContainerName,ContainerType |
    Sort-Object Subscription,ResourceGroupName,Name

#>

$AVsetsAll = $AVSets

$AVSets = $AVsetsAll | 
    Select-Object -Property Name,Subscription,ResourceGroupName,Location,PlatformFaultDomainCount,PlatformUpdateDomainCount |
    Sort-Object Subscription,ResourceGroupName,Name

$AVSetSizes = $AVsetsAll | 
    Select-Object -Property Name,Subscription,ResourceGroupName,Location,AvailVMSizesA,AvailVMSizesD,AvailVMSizesDv2,AvailVMSizesDv3 |
    Sort-Object Subscription,ResourceGroupName,Name



#endregion


#region Export, Open CSVs in C:\temp

$NowStr = Get-Date -Format yyyy.MM.dd_HH.mm

$mdStr = "C:\temp\$($NowStr)_RGInfo"

md $mdStr

$FilteredRGs | Export-Csv -Path "$($mdStr)\RGs.csv" -NoTypeInformation 
$VMs | Export-Csv -Path "$($mdStr)\VMs.csv" -NoTypeInformation 
$StorageAccounts | Export-Csv -Path "$($mdStr)\StorageAccounts.csv" -NoTypeInformation
$Disks | Export-Csv -Path "$($mdStr)\Disks.csv" -NoTypeInformation
$Vnets | Export-Csv -Path "$($mdStr)\Vnets.csv" -NoTypeInformation
$NetworkInterfaces | Export-Csv -Path "$($mdStr)\NetworkInterfaces.csv" -NoTypeInformation
$NSGs  | Export-Csv -Path "$($mdStr)\NSGs.csv" -NoTypeInformation
$AutoAccounts | Export-Csv -Path "$($mdStr)\AutoAccounts.csv" -NoTypeInformation
$LogAnalystics | Export-Csv -Path "$($mdStr)\LogAnalystics.csv" -NoTypeInformation
$KeyVaults | Export-Csv -Path "$($mdStr)\KeyVaults.csv" -NoTypeInformation
#$RecoveryServicesVaults | Export-Csv -Path "$($mdStr)\RecoveryServicesVaults.csv" -NoTypeInformation
#$BackupItemSummary  | Export-Csv -Path "$($mdStr)\BackupItemSummary.csv" -NoTypeInformation
$AVSets | Export-Csv -Path "$($mdStr)\AVSets.csv" -NoTypeInformation
$AVSetSizes | Export-Csv -Path "$($mdStr)\AVSetSizes.csv" -NoTypeInformation
#endregion


#region Build HTML Report, Export to C:\

$Report = @()
$HTMLmessage = ""
$HTMLMiddle = ""

Function Addh1($h1Text){
	# Create HTML Report for the current System being looped through
	$CurrentHTML = @"
	<hr noshade size=3 width="100%">
	
	<p><h1>$h1Text</p></h1>
"@
return $CurrentHTML
}

Function Addh2($h2Text){
	# Create HTML Report for the current System being looped through
	$CurrentHTML = @"
	<hr noshade size=3 width="75%">
	
	<p><h2>$h2Text</p></h2>
"@
return $CurrentHTML
}

function GenericTable ($TableInfo,$TableHeader,$TableComment ) {
$MyTableInfo = $TableInfo | ConvertTo-HTML -fragment

	# Create HTML Report for the current System being looped through
	$CurrentHTML += @"
	<h3>$TableHeader</h3>
	<p>$TableComment</p>
	<table class="normal">$MyTableInfo</table>	
"@

return $CurrentHTML
}

function VMs($VMs){

$MyTableInfo = $VMs | ConvertTo-HTML -fragment

	# Create HTML Report for the current System being looped through
	$CurrentHTML += @"
	<h3>VMs:</h3>
	<p>Detailed Azure VM Info</p>
	<table class="normal">$MyTableInfo</table>	
"@

return $CurrentHTML
}

$HTMLMiddle += AddH1 "Azure Resource Information Summary Report"
#$HTMLMiddle += AddH2 "SYSTEM: IAM"
$HTMLMiddle += GenericTable $FilteredRGs "Resource Groups" "Detailed Resource Group Info"
$HTMLMiddle += VMs $VMs
$HTMLMiddle += GenericTable $StorageAccounts "Storage Accounts" "Detailed Disk Info"
$HTMLMiddle += GenericTable $Disks  "Disks" "Detailed Disk Info"
$HTMLMiddle += GenericTable $Vnets "VNet" "Detailed VNet Info"
$HTMLMiddle += GenericTable $NetworkInterfaces "Network Interfaces" "Detailed Network Interface Info"
$HTMLMiddle += GenericTable $AutoAccounts  "Automation Accounts" "Detailed Automation Account Info"
$HTMLMiddle += GenericTable $LogAnalystics  "Log Analystics" "Detailed LogAnalystics Info"
$HTMLMiddle += GenericTable $KeyVaults "Key Vaults" "Detailed Key Vault Info"
#$HTMLMiddle += GenericTable $RecoveryServicesVaults "Recovery Services Vaults" "Detailed Vault Info"
#$HTMLMiddle += GenericTable $BackupItemSummary "Backup Item Summary" "Detailed Backup Item Summary Info"
$HTMLMiddle += GenericTable $AVSets "Availability Sets Info" "Detailed AVSet Info"
$HTMLMiddle += GenericTable $AVSetSizes "Availability Sets Available VM Sizes" "AVSet Available VM Sizes"

# Assemble the HTML Header and CSS for our Report
$HTMLHeader = @"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html><head><title>My Systems Report</title>
<style type="text/css">
<!--
body {
font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}

    #report { width: 835px; }

    table{
	border-collapse: collapse;
	border: none;
	font: 10pt Verdana, Geneva, Arial, Helvetica, sans-serif;
	color: black;
	margin-bottom: 10px;
}

    table td{
	font-size: 12px;
	padding-left: 0px;
	padding-right: 20px;
	text-align: left;
}

    table th {
	font-size: 12px;
	font-weight: bold;
	padding-left: 0px;
	padding-right: 20px;
	text-align: left;
}

h2{ clear: both; font-size: 130%; }

h3{
	clear: both;
	font-size: 115%;
	margin-left: 20px;
	margin-top: 30px;
}

p{ margin-left: 20px; font-size: 12px; }

table.list{ float: left; }

    table.list td:nth-child(1){
	font-weight: bold;
	border-right: 1px grey solid;
	text-align: right;
}

table.list td:nth-child(2){ padding-left: 7px; }
table tr:nth-child(even) td:nth-child(even){ background: #CCCCCC; }
table tr:nth-child(odd) td:nth-child(odd){ background: #F2F2F2; }
table tr:nth-child(even) td:nth-child(odd){ background: #DDDDDD; }
table tr:nth-child(odd) td:nth-child(even){ background: #E5E5E5; }
div.column { width: 320px; float: left; }
div.first{ padding-right: 20px; border-right: 1px  grey solid; }
div.second{ margin-left: 30px; }
table{ margin-left: 20px; }
-->
</style>
</head>
<body>

"@

# Assemble the closing HTML for our report.
$HTMLEnd = @"
</div>
</body>
</html>
"@

# Assemble the final report from all our HTML sections

$HTMLmessage = $HTMLHeader + $HTMLMiddle + $HTMLEnd
# Save the report out to a file in the current path
$HTMLmessage | Out-File -Force ("$($mdStr)\RGInfo.html")
# Email our report out
# send-mailmessage -from $fromemail -to $users -subject "Systems Report" -Attachments $ListOfAttachments -BodyAsHTML -body $HTMLmessage -priority Normal -smtpServer $server



#endregion


#region Zip Results

Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($mdStr, "$($mdStr).zip") 

#endregion


#region Open CSVs/Results in Explorer and Gridview

ii "$mdStr"

(Get-ChildItem $mdStr).FullName | Out-GridView -OutputMode Multiple -Title "Choose Files to Open" | ForEach-Object {Import-Csv $_ | Out-GridView -Title $_}

#endregion



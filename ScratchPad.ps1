$AVSets = $Null
$AVSets = Get-AzureRmAvailabilitySet
$AVSets[3].VirtualMachinesReferencesText

#$MyVM = Get-AzureRMVM -Name Ariel -ResourceGroupName Prod-RG

$MyVM = Get-AzureRMVM -Name VMResizeTest05 -ResourceGroupName Prod-RG | ForEach-Object { 
        $VMStatus = Get-AzureRMVM -Name $_.Name -ResourceGroupName Prod-RG -Status ;
        $_ | Add-Member -MemberType NoteProperty –Name PlatformFaultDomain –Value ($VMStatus.PlatformFaultDomain) -PassThru |
        Add-Member -MemberType NoteProperty –Name PlatformUpdateDomain –Value ($VMStatus.PlatformUpdateDomain) -PassThru 
    }

    $MyVM.PlatformFaultDomain
    $MyVM.PlatformUpdateDomain

    $MyVM =  Get-AzureRMVM -Name VMResizeTest05 -ResourceGroupName Prod-RG |
    foreach-object { $_ | Add-Member -MemberType NoteProperty –Name Size –Value ($_.HardwareProfile.Vmsize) -PassThru} |
    foreach-object { Get-AzureRmVm -Status -ResourceGroupName $RG.ResourceGroupName -Name $_.Name |   $_ | Add-Member -MemberType NoteProperty –Name FaultDomain –Value ($_.NetworkProfile.NetworkInterfaces.Capacity) -PassThru} 



$MyVMStatus = Get-AzureRMVM -Name $MyVM.Name -ResourceGroupName Prod-RG -Status
$MyVMStatus.PlatformFaultDomain
$MyVMStatus.PlatformUpdateDomain

If($MyVM.AvailabilitySetReference){$MyVM.AvailabilitySetReference.Id.Split("/")[8]}Else{$Null}

$MyVM.AvailabilitySetReference.Id.Split("/")[8]

$MyVM.NetworkProfile.NetworkInterfaces.Capacity
$MyVM.NetworkProfile.NetworkInterfaces.Count

$VMs.StorageProfile.OsDisk.OsType

$RGs[0] | get-azurermvm

$NetworkInterfaces[0].VirtualMachine.Id
$NetworkInterfaces[0].IpConfigurations[0].PrivateIpAddress

#if not logged in to Azure, start login
if ((Get-AzureRmContext).Account -eq $Null) {
    
    Connect-AzureRmAccount -Environment AzureUSGovernment}
    
    #List all subs:
    Get-AzureRmSubscription
    
    #Choose a Sub
    
    Get-AzureRmSubscription | 
        # Select-Object -Property Name,SubscriptionId,TenantId,State | 
        Out-GridView -OutputMode Single -Title  "Choose a Subscription" | Set-AzureRmContext


$NetworkInerfaces = Get-AzureRmNetworkInterface

$NetworkInerfaces.NetworkSecurityGroup.id | fl *

get-command -Noun "*Avail*"

(Get-AzureRmAvailabilitySet)[0] | Select-Object -Property ResourceGroupName, @{N='AvailabilitySetName';E={$_.Name}} | Get-AzureRmVMSize | Measure-Object

(Get-AzureRmAvailabilitySet)[0] |  Get-AzureRmVMSize | Measure-Object

Get-AzureRmVMSize -AvailabilitySetName

Show-Command Get-AzureRmVMSize
get-help Get-AzureRmVMSize -ShowWindow

#Tags Scratch

$VMs = Get-AzureRmVm

$UniqueTags = $VMs.Tags | Select-Object -ExpandProperty keys | Select-Object -Unique | Sort-Object

$VMsTags = @()

foreach ($VM in $VMs) {
    $VMTag = New-Object -TypeName PSObject
    Add-Member -InputObject $VMTag -MemberType NoteProperty -Name Name -Value $VM.Name
    
    foreach ($UniqueTag in $UniqueTags) {
        # Write-Host "UniqueTag $UniqueTag"
        # $VM.Tags
        $TagValue = $Null

        if ($VMs[0].Tags.ContainsKey("ProjectName") ) { 
            $TagValue = $VM.Tags.$UniqueTag
        }

        Add-Member -InputObject $VMTag -MemberType NoteProperty -Name $UniqueTag -Value $TagValue
    }
    $VMsTags += $VMTag
}

$VMsTags[0]

$VMsTags | Measure-Object
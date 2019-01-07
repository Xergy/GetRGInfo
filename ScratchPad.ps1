$AVSets = $Null
$AVSets = Get-AzureRmAvailabilitySet
$AVSets.VirtualMachinesReferences

$MyVM = Get-AzureRMVM -Name Ariel -ResourceGroupName Prod-RG

$MyVM

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

Get-AzureRmAvailabilitySet 


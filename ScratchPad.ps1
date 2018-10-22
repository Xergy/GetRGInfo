$MyVM = Get-AzureRMVM -Name Ariel -ResourceGroupName Prod-RG

$MyVM

$VMs.StorageProfile.OsDisk.OsType

#if not logged in to Azure, start login
if ((Get-AzureRmContext).Account -eq $Null) {
    
    Connect-AzureRmAccount -Environment AzureUSGovernment}
    
    #List all subs:
    Get-AzureRmSubscription
    
    #Choose a Sub
    
    Get-AzureRmSubscription | 
        # Select-Object -Property Name,SubscriptionId,TenantId,State | 
        Out-GridView -OutputMode Single -Title  "Choose a Subscription" | Set-AzureRmContext
$Mydisks = get-azurermdisk -ResourceGroupName Prod-RG

$Mydisks


#$MyVM = $VMsStatus | Where-Object {$_.name -eq "f5deployment-f5instance0"}

# $MyVM = get-azurermvm -ResourceGroupName Prod-RG -Name VMResizeTest05 -status

# $MyVM

# # $MyVault = Get-AzureRmRecoveryServicesVault -ResourceGroupName "Prod-RG"

# # Get-AzureRmRecoveryServicesAsrNotificationSetting -

# # Get-AzureRmNetworkSecurityGroup | Out-GridView

# # (Get-AzureRmNetworkSecurityGroup)[0] | fl *

# $NSGs = Get-AzureRmNetworkSecurityGroup | Select-Object -Property Name 

# $MyNSGs 
# # (Get-AzureRmNetworkSecurityGroup)[0] | fl *

# $MyNSGs 
# $NSGs_Filtered = @()

# foreach ($NSG in $NSGs) {
    
#     $NSGs_Filtered += $NSG | Select-Object -Property Name, ResourceGroupName, Location,
#         @{N='SecurityRuleName';E={
#                 ($_.SecurityRules.Name) -join " "
#                 } 
#          },
#          @{N='DefaultSecurityRuleName';E={
#                 ($_.DefaultSecurityRules.Name) -join " "
#                 } 
#          },
#          @{N='NetworkInterfaceName';E={
#             (  $_.NetworkInterfaces.ID.tostring().substring($_.NetworkInterfaces.ID.tostring().lastindexof('/')+1) ) -join " "
#             }
#          }, 
#          @{N='SubnetName';E={
#             (  $_.Subnets.ID.tostring().substring($_.Subnets.ID.tostring().lastindexof('/')+1) ) -join " "
#             } 
#         }        
# }

# $NSGs_Filtered

# # Select-Object -Property Name, @{Name="VMName";Expression = { $_.VirtualMachine.Id.tostring().substring($_.VirtualMachine.Id.tostring().lastindexof('/')+1) }
# # $NSGs[0].DefaultSecurityRules.Name 
# $NSGs_Filtered = @()
# $NSGs_Final = $NSGs | ForEach-Object {
#     $_ | Select-Object -Property Name, ResourceGroupName, Location,
#         @{N='SecurityRuleName';E={
#                 ($_.SecurityRules.Name) -join " "
#                 } 
#          },
#          @{N='DefaultSecurityRuleName';E={
#                 ($_.DefaultSecurityRules.Name) -join " "
#                 } 
#          },
#          @{N='NetworkInterfaceName';E={
#             (  $_.NetworkInterfaces.ID.tostring().substring($_.NetworkInterfaces.ID.tostring().lastindexof('/')+1) ) -join " "
#             }
#          }, 
#          @{N='SubnetName';E={
#             (  $_.Subnets.ID.tostring().substring($_.Subnets.ID.tostring().lastindexof('/')+1) ) -join " "
#             } 
#         }  
# }

# $NSGs_Final = @()
# $NSGs_Final = $NSGs | 
#     Select-Object -Property Name, ResourceGroupName, Location,
#         @{N='SecurityRuleName';E={
#                 ($_.SecurityRules.Name) -join " "
#                 } 
#          },
#          @{N='NetworkInterfaceName';E={
#             ($_.NetworkInterfaces.ID | ForEach-Object {$_.tostring().substring($_.tostring().lastindexof('/')+1) } ) -join " " 
#             }
#          }, 
#          @{N='SubnetName';E={
#             ( $_.Subnets.ID | ForEach-Object {$_.tostring().substring($_.tostring().lastindexof('/')+1) } ) -join " "
#             } 
#         }  

#         $NSGs_Final | ogv

# ($NSGs[0].NetworkInterfaces.Id) -join " "
# (  $NSGs[2].NetworkInterfaces.ID.tostring().substring($NSGs[2].NetworkInterfaces.ID.tostring().lastindexof('/')+1) ) -join " "



# ($NSGs[1].NetworkInterfaces.ID | ForEach-Object {$_.tostring().substring($_.tostring().lastindexof('/')+1) } ) -join " " 

# | Get-AzureRmVMSize | ForEach-Object { $_.Name} | Where-Object {$_ -like "Standard_F*" -and $_ -notlike "*promo*" } | ForEach-Object {$_.Replace("Standard_","") } | Sort-Object ) -join " " ;


# $NetworkInterfaces = Get-AzureRmNetworkInterface

# ($NetworkInterfaces[0].IpConfigurations.PrivateIpAddress) -join " "  


# $NetworkInterfaces +=  $RG |
# Get-AzureRmNetworkInterface |
# Add-Member -MemberType NoteProperty –Name Subscription –Value $RG.Subscription -PassThru |
# Add-Member -MemberType NoteProperty –Name SubscriptionId –Value $RG.SubscriptionID -PassThru |
# ForEach-Object { $_ | Add-Member -MemberType NoteProperty –Name PrivateIp –Value ($_.IpConfigurations[0].PrivateIpAddress) -PassThru} |
# Select-Object *,
#     @{N='NSG';E={
#         $_.NetworkSecurityGroup.id.tostring().substring($_.NetworkSecurityGroup.id.tostring().lastindexof('/')+1)
#         }
#     },
#     @{N='Owner';E={
#         $_.VirtualMachine.Id.tostring().substring($_.VirtualMachine.Id.tostring().lastindexof('/')+1)
#         }
#     },
#     @{N='PrivateIPs';E={
#         ($_.IpConfigurations.PrivateIpAddress) -join " "  
#         }
#     },
#     @{N='DnsServers';E={
#         ($_.DnsSettings.DnsServers) -join " "  
#         }
#     }


#     get-azurermvm -Status -ResourceGroupName Prod-RG | Select-Object -First 1 | fl *


#     ($vm | Get-AzureRmVM -Status).statuses)[1].code.split("/")[1]


#    $subscriptionId = '83dd191a-2254-42cb-bb78-a2394953b37c'



#    $VMs =  Get-AzureRmVM -ResourceGroupName $RG.ResourceGroupName

#    (($VMs[0] | Get-AzureRmVM -Status).statuses)[1].code.split("/")[1]

#    $VMStatus = Get-AzureRmVM -ResourceGroupName $RG.ResourceGroupName -Status | ForEach-Object { ($_.statuses)}

#    $VMStatus[0].PowerState

# $VMs[0] | fl *

# # VM Object, query VMstatus, get STatus, add as property

# $VMs[0] | ForEach-Object { 
#     $_ | foreach-object { $VM = $_ ;
#         $VMStatus | Where-Object {$VM.Name -eq $_.Name -and $VM.Location -eq $_.Location } |
#             foreach-object {$_.PowerState}
#     }  
# }

#                     $_ | ForEach-Object { 
#                         $_ | foreach-object { $VM = $_ ;
#                             $VMStatus | Where-Object {$VM.Name -eq $_.Name -and $VM.Location -eq $_.Location } |
#                                 foreach-object {$_.PowerState}
#                         }  
#                     }


#         $VMStatusTest = Get-AzureRmVM -ResourceGroupName $RG.ResourceGroupName -Status


#         Select-Object *,
#         @{N='PowerState';E={
#                 $_ | ForEach-Object { 
#                     $_ | foreach-object { $VM = $_ ;
#                         $VMStatus | Where-Object {$VM.Name -eq $_.Name -and $VM.Location -eq $_.Location } |
#                             foreach-object {$_.PowerState}
#                     }  
#                 }                    
#             }
#         }  

#         Get-AzureRmRecoveryServicesVault -ResourceGroupName Prod-RG

#         $responce = Invoke-RestMethod -Method Get -Uri $url -Headers @{ "Authorization" = "Bearer " + $accessToken }



#         $VMSizes = Get-AzureRmVMSize -Location $Locations
# $VMSizes | ogv
#         NumberOfCores MemoryInMB

#         $VMSizes | Select-Object -Property Name,NumberOfCores,MemoryInMB,
#             @{N='MemoryInGB';E={
#                 "{0:n2}" -f [int]($_.MemoryInMB)/[int]1024            
#                 } 
#             } 



# $Locations = @()
# $Locations = $RGs.Location | Select-Object -Unique
# $VMSizes = $Locations | 
#     foreach-object {
#         $Location = $_ ;
#         Get-AzureRmVMSize -Location $_ | 
#         Select-Object *, 
#             @{N='Location';E={$Location}},
#             @{N='MemoryInGB';E={"{0:n2}" -f [int]($_.MemoryInMB)/[int]1024}} 
#     } 
#     Select-Object -Property Name,NumberOfCores,MemoryInMB,

#     Add-Member -MemberType NoteProperty –Name FaultDomain –Value ($VMStatus.PlatformFaultDomain) -PassThru |
#     Add-Member -MemberType NoteProperty –Name UpdateDomain –Value ($VMStatus.PlatformUpdateDomain) -PassThru | 


# (($vm | Get-AzureRmVM -Status).statuses)[1].code.split("/")[1]

$Mydisks = get-azurermdisk -ResourceGroupName Prod-RG
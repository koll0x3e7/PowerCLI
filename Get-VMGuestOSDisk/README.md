# Get-VMGuestOSDisk.ps1

**.DESCRIPTION**  
Collect VM Guest OS data of a vSphere Server: Disk Path, Capacity (GB/B), FreeSpace (GB/B/P), Summary Storage Commited (GB/B) & VMware Tools Version.  
**.REQUIREMENT**  
Module: VMware.PowerCLI  
**.NOTES**  
Author: Raphael Koller (@0x3e4)  
**.PARAMETER -VcServer**  
IP or FQDN of the vSphere server. It's a mandatory parameter.  
**.PARAMETER -Log**  
Keep the report as a CSV/LOG saved on your file system. Default path is $LogPath.  
**.PARAMETER -LogPath**  
Specify a path for the CSV/LOG report. Default: ```$env:TEMP\$(Get-Date -format ddMMyyyy)_$($VcServer)_VMGuestOSDisk.csv```  
**.PARAMETER -Mail**  
Enable/Disable mail.  
**.PARAMETER -From**  
Modify the sender.  
**.PARAMETER -To**  
Modify the receiver.  
**.PARAMETER -Smtp**  
Modify the mail server.  
**.EXAMPLE normal output**  
```PS> .\Get-VMGuestOSDisk -VcServer vc00.contoso.com```   
**.EXAMPLE with logging**  
```PS> .\Get-VMGuestOSDisk -VcServer vc00.contoso.com -Log:$true -LogPath "$env:TEMP\$(Get-Date -format ddMMyyyy)_$($VcServer)_VMGuestOSDisk.csv"```   
**.EXAMPLE with a mail report**  
```PS> .\Get-VMGuestOSDisk -VcServer vc00.contoso.com -Mail:$true -From powershell@contoso.com -To report@contoso.com -Smtp mail.contoso.com```   
**.EXAMPLE with logging and a mail report**  
```PS> .\Get-VMGuestOSDisk -VcServer vc00.contoso.com -Log:$true -LogPath "$env:TEMP\$(Get-Date -format ddMMyyyy)_$($VcServer)_VMGuestOSDisk.csv" -Mail:$true -From powershell@contoso.com -To report@contoso.com -Smtp mail.contoso.com```   

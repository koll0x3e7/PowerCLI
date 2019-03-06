PARAM
(
    [Parameter(Mandatory=$true)]
    [System.IO.FileInfo]$VcServer,
    [switch]$Log = $false,
    [string]$LogPath = "$env:TEMP\$(Get-Date -format ddMMyyyy)_$($VcServer)_VMGuestOSDisk.csv",
    [switch]$Mail = $false,
    [string]$From,
    [string]$To,
    [string]$Smtp
)

<# README.md  
 .DESCRIPTION  
 Collect VM Guest OS data of a vSphere Server: Disk Path, Capacity (GB/B), FreeSpace (GB/B/P), Summary Storage Commited (GB/B) & VMware Tools Version.  
 .REQUIREMENT  
 Module: VMware.PowerCLI  
 .NOTES   
 Author: Raphael Koller (@0x3e4)  
 .PARAMETER -VcServer 
 IP or FQDN of the vSphere server. It's a mandatory parameter.  
 .PARAMETER -Log 
 Keep the report as a CSV/LOG saved on your file system. Default path is $LogPath.  
 .PARAMETER -LogPath 
 Specify a path for the CSV/LOG report. Default: "$env:TEMP\$(Get-Date -format ddMMyyyy)_$($VcServer)_VMGuestOSDisk.csv"  
 .PARAMETER -Mail 
 Enable/Disable mail.   
 .PARAMETER -From 
 Modify the sender.   
 .PARAMETER -To 
 Modify the receiver.   
 .PARAMETER -Smtp 
 Modify the mail server.   
 .EXAMPLE normal output  
 PS> .\Get-VMGuestOSDisk -VcServer vc00.contoso.com
 .EXAMPLE with logging  
 PS> .\Get-VMGuestOSDisk -VcServer vc00.contoso.com -Log:$true -LogPath "$env:TEMP\$(Get-Date -format ddMMyyyy)_$($VcServer)_VMGuestOSDisk.csv"
 .EXAMPLE with a mail report  
 PS> .\Get-VMGuestOSDisk -VcServer vc00.contoso.com -Mail:$true -From powershell@contoso.com -To report@contoso.com -Smtp mail.contoso.com
 .EXAMPLE with logging and a mail report  
 PS> .\Get-VMGuestOSDisk -VcServer vc00.contoso.com -Log:$true -LogPath "$env:TEMP\$(Get-Date -format ddMMyyyy)_$($VcServer)_VMGuestOSDisk.csv" -Mail:$true -From powershell@contoso.com -To report@contoso.com -Smtp mail.contoso.com
#>  

Connect-VIServer $VcServer

$allvminfo = @()

ForEach ($VM in $(Get-VM) ) {
    $vminfo = "" | Select Name, Cluster, GuestOSDiskPath, GuestOSCapacityGB, GuestOSCapacityB, GuestOSFreeSpaceGB, GuestOSFreeSpaceB, GuestOSFreeSpaceP, SummaryStorageCommittedGB, SummaryStorageCommittedB, VMwareTools
    if ($VM.Extensiondata.Guest.ToolsVersion -ne "0") {
        ForEach ($Disk in $VM.Extensiondata.Guest.Disk) {
            $vminfo.Name = $VM.Name
            $vminfo.Cluster = Get-Cluster -VM $VM.Name
            $vminfo.GuestOSDiskPath = $Disk.DiskPath
            $vminfo.GuestOSCapacityGB = [math]::Round($Disk.Capacity / 1GB)
            $vminfo.GuestOSCapacityB = [math]::Round($Disk.Capacity)
            $vminfo.GuestOSFreeSpaceGB = [math]::Round($Disk.FreeSpace / 1GB)
            $vminfo.GuestOSFreeSpaceB = [math]::Round($Disk.FreeSpace)
            $vminfo.GuestOSFreeSpaceP = [math]::Round(((100 * ($Disk.FreeSpace)) / ($Disk.Capacity)),0)
            $vminfo.SummaryStorageCommittedGB = [math]::Round($VM.Extensiondata.Summary.Storage.Committed / 1GB)
            $vminfo.SummaryStorageCommittedB = [math]::Round($VM.Extensiondata.Summary.Storage.Committed)
            $vminfo.VMwareTools = $VM.Extensiondata.Guest.ToolsVersion
            $vmresult = New-Object -TypeName PSObject -Property @{
        		Name = $vminfo.Name
                Cluster = $vminfo.Cluster
        		GuestOSDiskPath = $vminfo.GuestOSDiskPath
				GuestOSCapacityGB = $vminfo.GuestOSCapacityGB
                GuestOSCapacityB = $vminfo.GuestOSCapacityB
				GuestOSFreeSpaceGB = $vminfo.GuestOSFreeSpaceGB
				GuestOSFreeSpaceB = $vminfo.GuestOSFreeSpaceB
				GuestOSFreeSpaceP = $vminfo.GuestOSFreeSpaceP
				SummaryStorageCommittedGB = $vminfo.SummaryStorageCommittedGB
				SummaryStorageCommittedB = $vminfo.SummaryStorageCommittedB
                VMwareTools = $vminfo.VMwareTools
			}
            $allvminfo += $vmresult
        }
    }
    else {
        $vminfo.Name = $VM.Name
        $vminfo.Cluster = get-cluster -VM $VM.Name
        $vminfo.SummaryStorageCommittedGB = [math]::Round($VM.Extensiondata.Summary.Storage.Committed / 1GB)
        $vminfo.SummaryStorageCommittedB = [math]::Round($VM.Extensiondata.Summary.Storage.Committed)
        $vminfo.VMwareTools = $VM.Extensiondata.Guest.ToolsVersion
        $vmresult = New-Object -TypeName PSObject -Property @{
            Name = $vminfo.Name
            Cluster = $vminfo.Cluster
            FolderPath = $vminfo.FolderPath
            SummaryStorageCommittedGB = $vminfo.SummaryStorageCommittedGB
            SummaryStorageCommittedB = $vminfo.SummaryStorageCommittedB
            VMwareTools = $vminfo.VMwareTools
	}
    $allvminfo += $vmresult
    }
}

$allvminfo | Select Name, Cluster, GuestOSDiskPath, GuestOSCapacityGB, GuestOSCapacityB, GuestOSFreeSpaceGB, GuestOSFreeSpaceB, GuestOSFreeSpaceP, SummaryStorageCommittedGB, SummaryStorageCommittedB, VMwareTools | Export-CSV -Path $LogPath -NoTypeInformation -Encoding UTF8

Disconnect-VIServer $VcServer -Force -Confirm:$false

if($Mail -eq $true) {

    $body = "<html><head><meta http-equiv=""Content-Type"" content=""text/html"" /></head>"
    $body += "<body style=""font-family: Calibri; color: #000000;""><P>"
    $body += "Dear administrator,<p>"
    $body += "find the $VcServer report in the mail attachment or inside the following folder:"
    $body += "<ul style=""list-style-position: inside;""><li>Report: <a href=""$LogPath"">$LogPath</a></li></ul><p>"
    $body += "Your Robot."

    Send-MailMessage -From $From -To $to -Subject "$VcServer | VM Guest OS Disk" -BodyAsHtml -Body $body -SmtpServer $Smtp -Attachments $LogPath

}

if($Log -eq $false) {

    Remove-Item $LogPath -Confirm:$false -Force

}

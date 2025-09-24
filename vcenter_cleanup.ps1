# Load VMware PowerCLI module
Import-Module VMware.PowerCLI

# Define vCenter server and credential path
$vCenterServer = "vCenter_name"
$credPath = "C:\Users\user\vcenterCred.xml"

# Load credentials or prompt if not found
if (Test-Path $credPath) {
    $vcCredential = Import-Clixml -Path $credPath
} else {
    $vcCredential = Get-Credential
}

# Connect to vCenter
Connect-VIServer -Server $vCenterServer -Credential $vcCredential

# Load site IDs from text file (one per line)
$siteIds = Get-Content -Path "C:\Users\user\scripts\sites.txt"

foreach ($siteId in $siteIds) {
    Write-Host "`n--- Processing site: $siteId ---" -ForegroundColor Cyan

    # 1. Power off and delete VMs starting with siteId
    $vms = Get-VM -Name "$siteId*" -ErrorAction SilentlyContinue
    if ($vms) {
        Write-Host "Found $($vms.Count) VM(s) starting with '$siteId'."
        foreach ($vm in $vms) {
            if ($vm.PowerState -ne 'PoweredOff') {
                Write-Host "Powering off VM $($vm.Name)..."
                Stop-VM -VM $vm -Confirm:$false -ErrorAction Stop
            } else {
                Write-Host "VM $($vm.Name) is already powered off."
            }
            Write-Host "Deleting VM $($vm.Name) from disk..."
            Remove-VM -VM $vm -DeletePermanently -Confirm:$false -ErrorAction Stop
        }
    } else {
        Write-Host "No VMs found starting with '$siteId'." -ForegroundColor Yellow
    }

    # 2. Delete templates starting with tca-photon in folder <siteid>-FQDN
    $folderName = "$siteId-FQDN"
    $folder = Get-Folder -Name $folderName -ErrorAction SilentlyContinue
    if ($folder) {
        $templates = Get-Template -Location $folder -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "tca-photon*" }
        if ($templates.Count -gt 0) {
            foreach ($tmpl in $templates) {
                Write-Host "Removing template '$($tmpl.Name)' from folder '$folderName'..."
                Remove-Template -Template $tmpl -Confirm:$false -ErrorAction Stop
            }
        } else {
            Write-Host "No templates starting with 'tca-photon' found in folder '$folderName'." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Folder '$folderName' not found." -ForegroundColor Yellow
    }

    # 3. Enable SSH service on ESXi host <siteid>-FQDN
    $esxiHostName = $folderName
    $esxiHost = Get-VMHost -Name $esxiHostName -ErrorAction SilentlyContinue
    if ($esxiHost) {
        $sshService = Get-VMHostService -VMHost $esxiHost | Where-Object { $_.Key -eq "Txr-SSH" }
        if ($sshService -and -not $sshService.Running) {
            Write-Host "Starting SSH service on ESXi host $esxiHostName..."
            Start-VMHostService -HostService $sshService -Confirm:$false
        } else {
            Write-Host "SSH service is already running on $esxiHostName or service not found."
        }
    } else {
        Write-Host "ESXi host $esxiHostName not found." -ForegroundColor Yellow
    }
}

# Disconnect from vCenter
Disconnect-VIServer -Server $vCenterServer -Confirm:$false

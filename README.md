# VMware Site Cleanup Script

This PowerShell script automates the cleanup of VMware vSphere resources across multiple sites within a vCenter environment using **VMware PowerCLI**.

---

## 🔧 Features

- Connects to a specified vCenter server using secure credential loading (`Export-Clixml`)
- Reads site IDs from a text file (one site ID per line)
- For each site ID:
  - Powers off and permanently deletes VMs starting with the site ID prefix
  - Deletes templates starting with `tca-photon*` inside site-specific folders
  - Enables the SSH service on the ESXi host named after the site ID
- Handles missing credentials, VMs, templates, folders, or hosts gracefully
- Provides color-coded console output for easy monitoring

---

## 🧰 Prerequisites

- PowerShell 5.1 or PowerShell Core
- [VMware PowerCLI](https://developer.vmware.com/powercli) installed

---

## 📦 Setup Instructions

### Install VMware PowerCLI

```powershell
Install-Module -Name VMware.PowerCLI -Scope CurrentUser
Export vCenter Credentials
Run once to securely store your vCenter credentials:

powershell
Copy code
Get-Credential | Export-Clixml -Path "C:\Users\user\vcenterCred.xml"
Create Site List File
Create a sites.txt file listing all site IDs, one per line, for example:

nginx
Copy code
NYC
DAL
CHI
Place this file in a known location (e.g., C:\Users\user\scripts\sites.txt) and update the script path accordingly.

🗂 Project Structure
graphql
Copy code
vmware-site-cleanup/
├── vcenters_cleanup.ps1       # Main cleanup PowerShell script
├── README.md
└── data/
    └── sites.txt              # List of site IDs
▶️ How to Run
Update the script variables $vCenterServer, $credPath, and the path to sites.txt as needed.

Open PowerShell as Administrator.

Navigate to the script directory.

Execute the script:

powershell
Copy code
.\vcenters_cleanup.ps1

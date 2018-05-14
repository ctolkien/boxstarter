# Description: Boxstarter Script
# Author: Microsoft
# Common dev settings for web development

Disable-UAC

function Install-LatestFoundationModule {
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $ModuleName,
        [string] $ModuleVersion,

        [switch]$PassThru
    )

    if (-not $ModuleVersion) {
        $ModuleVersion = Find-Module -Name $ModuleName -Repository TechOpsPSGallery | % Version
    }

    $installedModules = Get-Module -Name $ModuleName -ListAvailable -ErrorAction SilentlyContinue
    if ($installedModules) {
        if (-not ($installedModules | ? { $_.Version -ge $ModuleVersion })) {
            Write-Host "Updating module $ModuleName to version $ModuleVersion"
            Update-Module -Name $ModuleName -RequiredVersion $ModuleVersion
        }

        # Uninstall other versions
        Get-Module -Name $ModuleName -ListAvailable -ErrorAction SilentlyContinue | ? Version -ne $ModuleVersion | % {
            Write-Host "Uninstalling older version $($_.Version) of module $ModuleName"
            Uninstall-Module -Name $ModuleName -RequiredVersion $_.Version -Force
        }
    }
    else {
        Write-Host "Installing module $ModuleName version $ModuleVersion"
        if ($PSVersionTable.PSVersion -ge "5.1.14393.103") {
            Install-Module -Name $ModuleName -RequiredVersion $ModuleVersion -Repository TechOpsPSGallery -Scope CurrentUser -AllowClobber
        }
        else {
            Install-Module -Name $ModuleName -RequiredVersion $ModuleVersion -Repository TechOpsPSGallery -Scope CurrentUser
        }
    }

    if ($PassThru) {
        $module = Import-Module -Name $ModuleName -Force -PassThru | ? Name -eq $ModuleName
        Write-Host "Imported version $($module.Version) of module $($module.Name) "
        $module
    }
}

Set-ExecutionPolicy Bypass -Force -Scope CurrentUser

if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction:SilentlyContinue | ? Version -ge '2.8.5.208')) {
    Install-PackageProvider -Name NuGet -MinimumVersion '2.8.5.208' -Force -Scope CurrentUser
}

Write-Host "Bootstrapping NuGet provider" -ForegroundColor Yellow
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Write-Host "Trusting Chocolatey package source" -ForegroundColor Yellow
Set-PackageSource -Name Chocolatey -Trusted -Force | Out-Null

Write-Host "Trusting PSGallery" -ForegroundColor Yellow
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

if (-not (Get-PSRepository -Name TechOpsPSGallery -ErrorAction:SilentlyContinue)) {
    Register-PSRepository -Name TechOpsPSGallery `
        -PackageManagementProvider NuGet `
        -SourceLocation https://www.myget.org/F/techops-psgallery/api/v2 `
        -PublishLocation https://www.myget.org/F/techops-psgallery/api/v2/package `
        -InstallationPolicy Trusted
}

Install-LatestFoundationModule FoundationUtil
Install-LatestFoundationModule Foundation

Write-Host "Installing ImportExcel module" -ForegroundColor Yellow
Install-Module -Name ImportExcel -Scope CurrentUser

Write-Host "Enabling Windows Authentication on FQDN intranet sites" -ForegroundColor Yellow
if (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\turner.com")) {
    New-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\turner.com" | Out-Null
}

Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\turner.com" -Name "*" -Type DWord -Value 1 -Force | Out-Null
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\WebClient\Parameters" -Name "AuthForwardServerList" -Type MultiString -Value "*.turner.com" -Force | Out-Null
Restart-Service WebClient

cmd.exe /c winrm quickconfig -force

Write-Host "Enabling CredSSP credentials" -ForegroundColor Yellow
Enable-WSManCredSSP -Role Client -DelegateComputer * -Force | Out-Null

Update-Help -Force

#--- Windows Features ---
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions

# Enable QuickEdit mode
Set-ItemProperty HKCU:\Console\ -name QuickEdit -value 1

#--- File Explorer Settings ---
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2

#--- Tools ---
choco install -y visualstudiocode
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'Visual Studio Code.lnk' } | Remove-Item

choco install -y git -params '"/GitAndUnixToolsOnPath /WindowsTerminal"'
choco install -y Git-Credential-Manager-for-Windows
choco install -y 7zip.install
choco install -y rsat
choco install -y DiffMerge --allow-empty-checksums
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'DiffMerge.lnk' } | Remove-Item

#--- Windows Subsystems/Features ---
choco install -y IIS-WebServerRole -source windowsFeatures
choco install -y Microsoft-Hyper-V-All -source windowsFeatures
choco install -y Microsoft-Windows-Subsystem-Linux -source windowsfeatures

#--- Ubuntu ---
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1604 -OutFile ~/Ubuntu.appx -UseBasicParsing
Add-AppxPackage -Path ~/Ubuntu.appx

#--- Browsers ---
choco install -y Googlechrome
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'Google Chrome.lnk' } | Remove-Item
choco install -y lastpass --ignore-checksums

#--- Fonts ---
choco install -y inconsolata
# choco install -y ubuntu.font

#--- Tools ---
choco install -y nodejs # Node.js Current, Latest features
choco install -y visualstudio2017buildtools
choco install -y visualstudio2017-workload-vctools
choco install -y sysinternals
choco install -y docker-for-windows
Get-ChildItem "$([Environment]::GetFolderPath('DesktopDirectory'))" | ? { $_.Name -eq 'Docker for Windows.lnk' } | Remove-Item
choco install -y python
RefreshEnv.cmd

choco install -y pip
choco install -y mongodb.install
Get-ChildItem "$([Environment]::GetFolderPath('DesktopDirectory'))" | ? { $_.Name -eq 'MongoDB Compass Community.lnk' } | Remove-Item
choco install -y kubernetes-cli
choco install -y terraform

choco install -y awscli
choco install -y azure-cli
Install-Module AWSPowerShell -Scope CurrentUser
Install-Module Azure -Scope CurrentUser

# Support for Turner logins to AWS using samld
[Environment]::SetEnvironmentVariable('ADFS_DOMAIN', 'TURNER', 'User')
[Environment]::SetEnvironmentVariable('ADFS_URL', 'https://sts.turner.com/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=urn:amazon:webservices', 'User')
pip install samlkeygen

choco install adobereader -y --allow-empty-checksums
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'Acrobat Reader DC.lnk' } | Remove-Item

choco install -y sql-server-management-studio

# Enable PIN and Windows Hello
Set-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -name AllowDomainPINLogon -value 1

choco install -y steam --allowEmptyCheckSum
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'Steam.lnk' } | Remove-Item
Remove-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name 'Steam' -ErrorAction SilentlyContinue

npm install -g npm npm-check-updates rimraf typescript@2.7.2 gulp @angular/cli

# Install 'Sauce Code Pro Nerd Font Complete Mono.ttf'

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

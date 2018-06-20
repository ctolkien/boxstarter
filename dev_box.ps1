# Inspired by https://github.com/Microsoft/windows-dev-box-setup-scripts

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
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions

# Enable QuickEdit mode
Set-ItemProperty HKCU:\Console\ -name QuickEdit -value 1

#--- File Explorer Settings ---
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2

# Enable PIN and Windows Hello
Set-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -name AllowDomainPINLogon -value 1

# Remove Windows Store Apps
Get-AppxPackage Microsoft.3DBuilder | Remove-AppxPackage
Get-AppxPackage *Autodesk* | Remove-AppxPackage
Get-AppxPackage Microsoft.BingFinance | Remove-AppxPackage
Get-AppxPackage Microsoft.BingNews | Remove-AppxPackage
Get-AppxPackage Microsoft.BingSports | Remove-AppxPackage
Get-AppxPackage *BubbleWitch* | Remove-AppxPackage
Get-AppxPackage king.com.CandyCrush* | Remove-AppxPackage
Get-AppxPackage Microsoft.CommsPhone | Remove-AppxPackage
Get-AppxPackage *Dropbox* | Remove-AppxPackage
Get-AppxPackage Microsoft.Getstarted | Remove-AppxPackage
Get-AppxPackage *Keeper* | Remove-AppxPackage
Get-AppxPackage *MarchofEmpires* | Remove-AppxPackage
Get-AppxPackage Microsoft.Messaging | Remove-AppxPackage
Get-AppxPackage *Minecraft* | Remove-AppxPackage
Get-AppxPackage Microsoft.MicrosoftOfficeHub | Remove-AppxPackage
Get-AppxPackage Microsoft.OneConnect | Remove-AppxPackage
Get-AppxPackage Microsoft.WindowsPhone | Remove-AppxPackage
Get-AppxPackage *Plex* | Remove-AppxPackage
Get-AppxPackage Microsoft.SkypeApp | Remove-AppxPackage
Get-AppxPackage Microsoft.WindowsSoundRecorder | Remove-AppxPackage
Get-AppxPackage *Solitaire* | Remove-AppxPackage
Get-AppxPackage Microsoft.MicrosoftStickyNotes | Remove-AppxPackage
Get-AppxPackage Microsoft.Office.Sway | Remove-AppxPackage
Get-AppxPackage Microsoft.XboxApp | Remove-AppxPackage
Get-AppxPackage Microsoft.XboxIdentityProvider | Remove-AppxPackage
Get-AppxPackage Microsoft.ZuneMusic | Remove-AppxPackage
Get-AppxPackage Microsoft.ZuneVideo | Remove-AppxPackage

#--- Windows Subsystems/Features ---
choco install -y IIS-WebServerRole -source windowsFeatures
choco install -y Microsoft-Hyper-V-All -source windowsFeatures
choco install -y Microsoft-Windows-Subsystem-Linux -source windowsfeatures

#--- Ubuntu ---
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile ~/Ubuntu.appx -UseBasicParsing
Add-AppxPackage -Path ~/Ubuntu.appx
Remove-Item ~/Ubuntu.appx

#--- Browsers ---
choco install -y Googlechrome
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'Google Chrome.lnk' } | Remove-Item
choco install -y lastpass --ignore-checksums

#--- Fonts ---
#choco install -y inconsolata
if (-not (Get-ChildItem ([Environment]::GetFolderPath('Fonts')) | ? Name -eq 'Sauce Code Pro Nerd Font Complete Mono.ttf')) {
    if (Test-Path "$env:TEMP\SourceCodePro.zip") { Remove-Item "$env:TEMP\SourceCodePro.zip" }
    Invoke-WebRequest https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/SourceCodePro.zip -OutFile "$env:TEMP\SourceCodePro.zip"
    Expand-Archive "$env:TEMP\SourceCodePro.zip" -DestinationPath "$env:TEMP\SourceCodePro"
    $fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
    Get-Item "$env:TEMP\SourceCodePro\Sauce Code Pro Nerd Font Complete Mono.ttf" | % { $fonts.CopyHere($_.fullname) }
    Remove-Item "$env:TEMP\SourceCodePro.zip" -Force
    Remove-Item "$env:TEMP\SourceCodePro" -Recurse -Force
}

choco install -y git -params '"/NoShellIntegration /NoAutoCrlf /WindowsTerminal /SChannel"'
choco install -y 7zip.install
choco install -y rsat
choco install -y DiffMerge --allow-empty-checksums
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'DiffMerge.lnk' } | Remove-Item
choco install adobereader -y --allow-empty-checksums
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'Acrobat Reader DC.lnk' } | Remove-Item
choco install -y sql-server-management-studio
choco install -y nodejs # Node.js Current, Latest features
choco install -y sysinternals
choco install -y cmder
choco install -y docker-for-windows
Get-ChildItem "$([Environment]::GetFolderPath('DesktopDirectory'))" | ? { $_.Name -eq 'Docker for Windows.lnk' } | Remove-Item
choco install -y python --installargs Include_pip=1
Update-SessionEnvironment

#choco install -y pip
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

#--- VS Code ---
choco install -y vscode
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'Visual Studio Code.lnk' } | Remove-Item
Update-SessionEnvironment
code --install-extension shan.code-settings-sync
code --install-extension msjsdiag.debugger-for-chrome
code --install-extension msjsdiag.debugger-for-edge



choco install -y visualstudio2017enterprise
choco install -y visualstudio2017buildtools
choco install -y visualstudio2017-workload-netweb
choco install -y visualstudio2017-workload-webbuildtools
choco install -y visualstudio2017-workload-netcoretools


choco install -y steam --allowEmptyCheckSum
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'Steam.lnk' } | Remove-Item
Remove-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name 'Steam' -ErrorAction SilentlyContinue

npm install -g npm npm-check-updates rimraf typescript@2.7.2 gulp @angular/cli

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

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

Write-Host "Installing PowerShell modules" -ForegroundColor Yellow
Install-LatestFoundationModule FoundationUtil
Install-LatestFoundationModule Foundation
Install-Module -Name ImportExcel -Scope CurrentUser
Install-Module -Name VSTeam -Scope CurrentUser

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
Get-AppxPackage Microsoft.BingFinance | Remove-AppxPackage
Get-AppxPackage Microsoft.BingNews | Remove-AppxPackage
Get-AppxPackage Microsoft.BingSports | Remove-AppxPackage
Get-AppxPackage Microsoft.CommsPhone | Remove-AppxPackage
Get-AppxPackage Microsoft.Getstarted | Remove-AppxPackage
Get-AppxPackage Microsoft.Messaging | Remove-AppxPackage
Get-AppxPackage Microsoft.MicrosoftOfficeHub | Remove-AppxPackage
Get-AppxPackage Microsoft.OneConnect | Remove-AppxPackage
Get-AppxPackage Microsoft.WindowsPhone | Remove-AppxPackage
Get-AppxPackage Microsoft.SkypeApp | Remove-AppxPackage
Get-AppxPackage Microsoft.WindowsSoundRecorder | Remove-AppxPackage
Get-AppxPackage Microsoft.MicrosoftStickyNotes | Remove-AppxPackage
Get-AppxPackage Microsoft.Office.Sway | Remove-AppxPackage
Get-AppxPackage Microsoft.XboxApp | Remove-AppxPackage
Get-AppxPackage Microsoft.XboxIdentityProvider | Remove-AppxPackage
Get-AppxPackage Microsoft.ZuneMusic | Remove-AppxPackage
Get-AppxPackage Microsoft.ZuneVideo | Remove-AppxPackage
Get-AppxPackage *Autodesk* | Remove-AppxPackage
Get-AppxPackage ActiproSoftware* | Remove-AppxPackage
Get-AppxPackage *EclipseManager | Remove-AppxPackage
Get-AppxPackage *AdobePhotoshopExpress | Remove-AppxPackage
Get-AppxPackage *Dualingo* | Remove-AppxPackage
Get-AppxPackage *Dropbox* | Remove-AppxPackage
Get-AppxPackage *BubbleWitch* | Remove-AppxPackage
Get-AppxPackage king.com.CandyCrush* | Remove-AppxPackage
Get-AppxPackage *Keeper* | Remove-AppxPackage
Get-AppxPackage *Minecraft* | Remove-AppxPackage
Get-AppxPackage *MarchofEmpires* | Remove-AppxPackage
Get-AppxPackage *Plex* | Remove-AppxPackage
Get-AppxPackage *Solitaire* | Remove-AppxPackage

#--- Windows Subsystems/Features ---
choco install -y IIS-WebServerRole -source windowsFeatures
choco install -y Microsoft-Hyper-V-All -source windowsFeatures
choco install -y Microsoft-Windows-Subsystem-Linux -source windowsfeatures

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


Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

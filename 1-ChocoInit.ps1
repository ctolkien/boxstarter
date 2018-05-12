function Install-LatestFoundationModule
{
	param
	(
		[Parameter(Mandatory=$true)]
        [string] $ModuleName,
        [string] $ModuleVersion,
		
        [switch]$PassThru
	)

	if (-not $ModuleVersion)
	{	
		$ModuleVersion = Find-Module -Name $ModuleName -Repository TechOpsPSGallery | % Version
	}

	$installedModules = Get-Module -Name $ModuleName -ListAvailable -ErrorAction SilentlyContinue
	if ($installedModules)	
	{
		if (-not ($installedModules | ?{ $_.Version -ge $ModuleVersion }))
		{
			Write-Host "Updating module $ModuleName to version $ModuleVersion"
			Update-Module -Name $ModuleName -RequiredVersion $ModuleVersion
		}

		# Uninstall other versions			
		Get-Module -Name $ModuleName -ListAvailable -ErrorAction SilentlyContinue | ? Version -ne $ModuleVersion | %{
			Write-Host "Uninstalling older version $($_.Version) of module $ModuleName"
			Uninstall-Module -Name $ModuleName -RequiredVersion $_.Version -Force
		}
	} 
	else
	{
		Write-Host "Installing module $ModuleName version $ModuleVersion"
		if ($PSVersionTable.PSVersion -ge "5.1.14393.103")
		{
			Install-Module -Name $ModuleName -RequiredVersion $ModuleVersion -Repository TechOpsPSGallery -Scope CurrentUser -AllowClobber
		}
		else
		{
			Install-Module -Name $ModuleName -RequiredVersion $ModuleVersion -Repository TechOpsPSGallery -Scope CurrentUser
		}
	}

	if ($PassThru)
	{
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
if (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\turner.com")) 
{
	New-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\turner.com" | Out-Null
}

Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\turner.com" -Name "*" -Type DWord -Value 1 -Force | Out-Null
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\WebClient\Parameters" -Name "AuthForwardServerList" -Type MultiString -Value "*.turner.com" -Force | Out-Null
Restart-Service WebClient

cmd.exe /c winrm quickconfig -force

Write-Host "Enabling CredSSP credentials" -ForegroundColor Yellow
Enable-WSManCredSSP -Role Client -DelegateComputer * -Force | Out-Null

Update-Help -Force

# Show file extensions
Set-ItemProperty HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ -name HideFileExt -value 0

# Show hidden files
Set-ItemProperty HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ -name Hidden -value 1

# Enable QuickEdit mode
Set-ItemProperty HKCU:\Console\ -name QuickEdit -value 1

iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Bash
$RegistryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
if (-not(Test-Path -Path $RegistryKeyPath)) {
    New-Item -Path $RegistryKeyPath -ItemType Directory -Force
}
New-ItemProperty -Path $RegistryKeyPath -Name AllowDevelopmentWithoutDevLicense -PropertyType DWORD -Value 1
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Windows-Subsystem-Linux

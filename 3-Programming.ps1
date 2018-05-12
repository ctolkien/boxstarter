Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Hyper-V-All, IIS-WebServerRole

cli tfx-cli yo 2>$null

choco install docker-for-windows -y
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'Docker for Windows.lnk' } | Remove-Item

choco install dotnetcore -y
choco install dotnetcore-sdk -y

# Bash
$RegistryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
if (-not(Test-Path -Path $RegistryKeyPath)) {
	New-Item -Path $RegistryKeyPath -ItemType Directory -Force
}
New-ItemProperty -Path $RegistryKeyPath -Name AllowDevelopmentWithoutDevLicense -PropertyType DWORD -Value 1
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Windows-Subsystem-Linux


# npm packages
#npm install --add-python-to-path --global --production windows-build-tools
#[Environment]::SetEnvironmentVariable('PYTHON', '%USERPROFILE%\.windows-build-tools\python27\python.exe', 'User')
npm install -g npm npm-check-updates node-gyp rimraf concurrently rimraf typescript webpack gulp @angular/cli

# Inspired by https://github.com/Microsoft/windows-dev-box-setup-scripts

Disable-UAC

#--- Ubuntu ---
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile ~/Ubuntu.appx -UseBasicParsing
Add-AppxPackage -Path ~/Ubuntu.appx
Remove-Item ~/Ubuntu.appx

#--- Browsers ---
choco install -y Googlechrome
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'Google Chrome.lnk' } | Remove-Item
choco install -y lastpass --ignore-checksums

#--- Tools ---
choco install -y sql-server-management-studio
choco install -y git -params '"/NoShellIntegration /NoAutoCrlf /WindowsTerminal /SChannel"'
choco install -y 7zip.install
choco install -y rsat
choco install -y DiffMerge --allow-empty-checksums
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'DiffMerge.lnk' } | Remove-Item
choco install -y nodejs # Node.js Current, Latest features
choco install -y sysinternals
choco install -y cmder
choco install -y docker-for-windows
Get-ChildItem "$([Environment]::GetFolderPath('DesktopDirectory'))" | ? { $_.Name -eq 'Docker for Windows.lnk' } | Remove-Item
choco install -y python
RefreshEnv.cmd

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
RefreshEnv.cmd
code --install-extension shan.code-settings-sync
code --install-extension msjsdiag.debugger-for-chrome
code --install-extension msjsdiag.debugger-for-edge

#--- Visual Studio ---
choco install -y visualstudio2017enterprise
choco install -y visualstudio2017buildtools
choco install -y visualstudio2017-workload-netweb
choco install -y visualstudio2017-workload-webbuildtools
choco install -y visualstudio2017-workload-netcoretools


#--- Applications ---
choco install -y steam --allowEmptyCheckSum
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'Steam.lnk' } | Remove-Item
Remove-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name 'Steam' -ErrorAction SilentlyContinue
choco install adobereader -y --allow-empty-checksums
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'Acrobat Reader DC.lnk' } | Remove-Item

npm install -g npm npm-check-updates rimraf typescript@2.7.2 gulp @angular/cli 2>$null


function EnsurePath {
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    if (-not (Test-Path $Path)) { New-Item -ItemType Directory -Path $Path | Out-Null }
}


EnsurePath c:\Projects
EnsurePath c:\Projects\RobCannon
EnsurePath c:\Projects\GitHub
EnsurePath c:\Projects\BuildServers
EnsurePath c:\Projects\Foundation
EnsurePath c:\Projects\PowerShellModules
EnsurePath c:\Projects\Servers
EnsurePath c:\Projects\TechOps


Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

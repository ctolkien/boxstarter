choco install office365proplus -y

# Browser stuff
choco install googlechrome -y
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'Google Chrome.lnk' } | Remove-Item

choco install lastpass -y --ignore-checksums

# Text Editors
choco install visualstudiocode -y
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'Visual Studio Code.lnk' } | Remove-Item

# Utilities
choco install rsat -y
choco install openssh -y -params "/SSHServerFeature"
choco install adobereader -y --allow-empty-checksums
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'Acrobat Reader DC.lnk' } | Remove-Item

choco install 7zip.install -y
choco install git.install -y --allow-empty-checksums
choco install sysinternals -y --allow-empty-checksums

choco install DiffMerge -y --allow-empty-checksums
Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'DiffMerge.lnk' } | Remove-Item

# Development
choco install nodejs.install -y
choco install mongodb.install -y
choco install kubernetes-cli -y
choco install terraform -y
choco install python -y
RefreshEnv.cmd

choco install awscli -y 
choco install azure-cli -y
Install-Module AWSPowerShell -Scope CurrentUser
Install-Module Azure -Scope CurrentUser

[Environment]::SetEnvironmentVariable('ADFS_DOMAIN', 'TURNER', 'User')
[Environment]::SetEnvironmentVariable('ADFS_URL', 'https://sts.turner.com/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=urn:amazon:webservices', 'User')

pip install samlkeygen


choco install sql-server-management-studio -y
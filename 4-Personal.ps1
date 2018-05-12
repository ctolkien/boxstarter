# Enable PIN and Windows Hello
Set-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -name AllowDomainPINLogon -value 1

choco install steam -y --allowEmptyCheckSum

Get-ChildItem "$([Environment]::GetFolderPath('CommonDesktopDirectory'))" | ? { $_.Name -eq 'Steam.lnk' } | Remove-Item
Remove-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name 'Steam' -ErrorAction SilentlyContinue
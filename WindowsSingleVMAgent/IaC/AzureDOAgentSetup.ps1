$agentURI = "https://vstsagentpackage.azureedge.net/agent/3.234.0/vsts-agent-win-x64-3.234.0.zip"

$destination = "$HOME\Downloads\vsts-agent-win-x64-3.234.0.zip"
Invoke-WebRequest -Uri $agentURI -OutFile $destination

Set-Location -Path "$HOME\Downloads"

$agentDir = "agent"
New-Item -ItemType Directory -Path $agentDir
Set-Location -Path $agentDir
Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$HOME\Downloads\vsts-agent-win-x64-3.234.0.zip", "$PWD")

.\config.cmd --unattended --url "#{AZDO_ORG_SERVICE_URL}#" --auth pat --token "#{AZDO_PERSONAL_ACCESS_TOKEN}#" --pool "#{azure-do-agent-pool-name}#" --agent "windows-vm-2022" --runAsService --runAsAutoLogon --windowsLogonAccount "#{vm_admin_username}#" --windowsLogonPassword '#{vm_admin_password}#'
$agentURI = "https://vstsagentpackage.azureedge.net/agent/3.234.0/vsts-agent-win-x64-3.234.0.zip"

$destination = "$HOME\Downloads\vsts-agent-win-x64-3.234.0.zip"
Invoke-WebRequest -Uri $agentURI -OutFile $destination

Set-Location -Path "$HOME\Downloads"

$agentDir = "agent"
New-Item -ItemType Directory -Path $agentDir
Set-Location -Path $agentDir
Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$HOME\Downloads\vsts-agent-win-x64-3.234.0.zip", "$PWD")

.\config.cmd --unattended --url "https://dev.azure.com/RichCorner" --auth pat --token "<your-pat>" --pool "<pool-name>" --agent "<agent-name>" --runAsService --runAsAutoLogon --windowsLogonAccount '<vm-computer-name>\<user-name>' --windowsLogonPassword '<user-password>'
# Get the path to the user's Downloads directory
$defaultWorkingDirectory = [System.Environment]::GetFolderPath("MyDocuments")
Set-Location -Path $defaultWorkingDirectory

$downloadDirectory = "$defaultWorkingDirectory\Downloads"
New-Item -ItemType Directory -Path $downloadDirectory
Set-Location -Path $downloadDirectory

$agentVersion = "3.234.0";
$agentURI = "https://vstsagentpackage.azureedge.net/agent/$agentVersion/vsts-agent-win-x64-$agentVersion.zip"

$destination =  "$downloadDirectory\vsts-agent-win-x64-$agentVersion.zip"
Invoke-WebRequest -Uri $agentURI -OutFile $destination

$agentDir = "agent"
New-Item -ItemType Directory -Path $agentDir
Set-Location -Path $agentDir
Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$destination", "$PWD")

.\config.cmd --unattended --url "#{AZDO_ORG_SERVICE_URL}#" --auth pat --token "#{AZDO_PERSONAL_ACCESS_TOKEN}#" --pool "#{azure_do_agent_pool_name}#" --agent "windows-vm-2022" --runAsService --runAsAutoLogon --windowsLogonAccount "#{vm_admin_username}#" --windowsLogonPassword '#{vm_admin_password}#'
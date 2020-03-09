Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction']='Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'

$epirus_version = $(Invoke-WebRequest -UseBasicParsing -Uri https://internal.services.web3labs.com/api/versions/latest).content

New-Item -Force -ItemType directory -Path "${env:USERPROFILE}\.epirus" | Out-Null
$url = "https://github.com/epirus-io/epirus-cli/releases/download/v${epirus_version}/epirus-${epirus_version}.zip"
$output = "${env:USERPROFILE}\.epirus\epirus.zip"
Write-Output "Downloading Epirus version ${epirus_version}..."
Invoke-WebRequest -Uri $url -OutFile $output
Write-Output "Extracting Epirus..."
Expand-Archive -Path "${env:USERPROFILE}\.epirus\epirus.zip" -DestinationPath "${env:USERPROFILE}\.epirus\" -Force
$CurrentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)

if (!($CurrentPath -match $epirus_version)) {
    [Environment]::SetEnvironmentVariable(
            "Path",
            $CurrentPath + ";${env:USERPROFILE}\.epirus\epirus-${epirus_version}\bin",
            [EnvironmentVariableTarget]::User)
    Write-Output "Epirus has been added to your PATH variable. You will need to open a new CMD/PowerShell instance to use it."
}

Write-Output "Epirus has been successfully installed (assuming errors were printed to your console)."

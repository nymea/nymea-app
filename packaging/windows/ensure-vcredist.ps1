param(
    [string]$DestinationDir = (Join-Path $PSScriptRoot "..\..\3rdParty\windows\vc_redist")
)

$ErrorActionPreference = "Stop"

$destinationPath = Join-Path $DestinationDir "vc_redist.x64.exe"

if (Test-Path -LiteralPath $destinationPath) {
    Write-Host "Using cached $destinationPath"
    exit 0
}

New-Item -ItemType Directory -Force -Path $DestinationDir | Out-Null

# Microsoft's "latest supported" redistributable - a stable URL that always resolves to the
# current VC++ runtime. Per Microsoft, this is compatible with apps built by any MSVC toolset
# from VS2015 through the current version (they share the same runtime/ABI).
$url = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
Write-Host "Downloading $url to $destinationPath"
Invoke-WebRequest -Uri $url -OutFile $destinationPath

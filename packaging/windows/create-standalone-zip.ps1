param(
    [string]$Workspace = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$workspacePath = (Resolve-Path -LiteralPath $Workspace).Path

function Copy-InstallerToWorkspaceRoot {
    param(
        [System.IO.FileInfo]$InstallerFile
    )

    $installerDestination = Join-Path $workspacePath $InstallerFile.Name
    if ([System.IO.Path]::GetFullPath($InstallerFile.FullName) -ieq [System.IO.Path]::GetFullPath($installerDestination)) {
        Write-Host ("Installer already in workspace root: " + $installerDestination)
        return
    }

    Write-Host ("Copying installer to workspace root: " + $installerDestination)
    Copy-Item -LiteralPath $InstallerFile.FullName -Destination $installerDestination -Force

    if (-not (Test-Path -LiteralPath $installerDestination -PathType Leaf)) {
        throw "Failed to copy Windows installer EXE to workspace root: $installerDestination"
    }
}

$installers = Get-ChildItem -LiteralPath $workspacePath -Filter "*-win-installer-*.exe" -File -Recurse |
    Sort-Object LastWriteTime -Descending

$installer = $installers | Select-Object -First 1

if (-not $installer) {
    $installerScript = Get-ChildItem -LiteralPath $workspacePath -Filter "installer.iss" -File -Recurse |
        Where-Object { $_.FullName -match "\\nymea-app\\installer\.iss$" } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($installerScript) {
        $iscc = Get-Command "iscc.exe" -ErrorAction SilentlyContinue
        if (-not $iscc) {
            $iscc = Get-Command "iscc" -ErrorAction SilentlyContinue
        }

        if ($iscc) {
            Write-Host ("No installer EXE found. Running Inno Setup compiler: " + $iscc.Source)
            Write-Host ("Using installer script: " + $installerScript.FullName)
            & $iscc.Source $installerScript.FullName
            if ($LASTEXITCODE -ne 0) {
                throw "Inno Setup compiler failed with exit code $LASTEXITCODE."
            }

            $installers = Get-ChildItem -LiteralPath $workspacePath -Filter "*-win-installer-*.exe" -File -Recurse |
                Sort-Object LastWriteTime -Descending
            $installer = $installers | Select-Object -First 1
            if (-not $installer) {
                throw "Inno Setup compiler completed but no Windows installer EXE matching '*-win-installer-*.exe' was created below '$workspacePath'."
            }
        } else {
            throw "No installer EXE found and Inno Setup compiler 'iscc' is not available on PATH."
        }
    } else {
        Write-Warning "No installer EXE found and no generated nymea-app\installer.iss found below '$workspacePath'."
    }
}

$packageDataDirs = Get-ChildItem -LiteralPath $workspacePath -Directory -Recurse -Filter data |
    Where-Object { $_.FullName -match "\\packaging\\windows\\packages\\[^\\]+\\data$" } |
    ForEach-Object {
        $applicationExe = Get-ChildItem -LiteralPath $_.FullName -Filter "*.exe" -File |
            Where-Object { $_.Name -ne "vc_redist.x64.exe" -and $_.Name -notlike "unins*.exe" } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

        if ($applicationExe) {
            [PSCustomObject]@{
                DataDirectory = $_
                ApplicationExe = $applicationExe
            }
        }
    }

$packageData = $packageDataDirs |
    Sort-Object { $_.ApplicationExe.LastWriteTime } -Descending |
    Select-Object -First 1

if (-not $packageData) {
    throw "No Windows package data directory containing an application EXE found below '$workspacePath'."
}

if ($installer) {
    $zipBaseName = $installer.BaseName
    Write-Host ("Using installer: " + $installer.FullName)

    foreach ($installerToCopy in $installers) {
        Copy-InstallerToWorkspaceRoot -InstallerFile $installerToCopy
    }
} else {
    $versionFile = Join-Path $workspacePath "version.txt"
    if (Test-Path -LiteralPath $versionFile) {
        $appVersion = ((Get-Content -LiteralPath $versionFile -TotalCount 1) -split "\s+")[0]
        $zipBaseName = $packageData.ApplicationExe.BaseName + "-win-installer-" + $appVersion
    } else {
        $zipBaseName = $packageData.ApplicationExe.BaseName + "-win"
    }
    Write-Warning "No Windows installer EXE matching '*-win-installer-*.exe' found below '$workspacePath'. Creating standalone ZIP from packaged application data only."
}

$zipDestination = Join-Path $workspacePath ($zipBaseName + "-standalone.zip")

Write-Host ("Using package data directory: " + $packageData.DataDirectory.FullName)
Write-Host ("Using packaged application: " + $packageData.ApplicationExe.FullName)
Write-Host ("Creating standalone ZIP: " + $zipDestination)

Compress-Archive -Path (Join-Path $packageData.DataDirectory.FullName "*") -DestinationPath $zipDestination -Force

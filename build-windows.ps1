param(
    [string]$GodotPath = "godot"
)

$ErrorActionPreference = "Stop"
$ProjectPath = $PSScriptRoot
$OutputDirectory = Join-Path $ProjectPath "exports/windows"
$OutputFile = Join-Path $OutputDirectory "project-hearth.exe"

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
& $GodotPath --headless --path $ProjectPath --export-debug "Windows Debug" $OutputFile
if ($LASTEXITCODE -ne 0) {
    throw "Godot export failed with exit code $LASTEXITCODE."
}

Write-Host "Windows build created: $OutputFile"
Write-Host "Run project-hearth.exe, then connect to ws://<MAC-LAN-IP>:9080"

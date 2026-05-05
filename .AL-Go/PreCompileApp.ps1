Param(
    [ValidateSet('app','testApp')]
    [string] ,
    [ref] 
)

Stop = "Stop"

# Skip when not running in GitHub Actions (e.g. localDevEnv.ps1 / local builds)
 = 
if ([string]::IsNullOrWhiteSpace() -or .Trim().ToLowerInvariant() -eq "false") {
    Write-Host "Not running in GitHub Actions. Skipping ALCops analyzer install."
    return
}

 = Join-Path  ".alcops"

# PreCompileApp runs once per app group (apps + testApps). Skip if analyzers
# are already on disk so we don't re-download for the testApp pass.
if ((Test-Path ) -and
    @(Get-ChildItem -Path  -Filter '*.dll' -ErrorAction SilentlyContinue).Count -gt 0) {
    Write-Host "ALCops analyzers already present in . Skipping download (appType=)."
    return
}

Write-Host "Installing ALCops analyzers (appType=)..."
Write-Host "  Output path: "
Write-Host "  Detect using: "

npx --yes '@alcops/core' download 
    --output  
    --detect-using  
    --detect-from bc-artifact

if (0 -ne 0) {
    throw "ALCops download failed with exit code 0"
}

Write-Host "ALCops analyzers installed successfully."
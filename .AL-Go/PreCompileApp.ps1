Param(
    [ValidateSet('app','testApp')]
    [string] $appType,
    [ref] $compilationParams
)

$ErrorActionPreference = "Stop"

# Skip when not running in GitHub Actions (e.g. localDevEnv.ps1 / local builds)
$githubActions = $env:GITHUB_ACTIONS
if ([string]::IsNullOrWhiteSpace($githubActions) -or $githubActions.Trim().ToLowerInvariant() -eq "false") {
    Write-Host "Not running in GitHub Actions. Skipping ALCops analyzer install."
    return
}

$outputPath = Join-Path $env:GITHUB_WORKSPACE ".alcops"

# PreCompileApp runs once per app group (apps + testApps). Skip if analyzers
# are already on disk so we don't re-download for the testApp pass.
if ((Test-Path $outputPath) -and
    @(Get-ChildItem -Path $outputPath -Filter '*.dll' -ErrorAction SilentlyContinue).Count -gt 0) {
    Write-Host "ALCops analyzers already present in $outputPath. Skipping download (appType=$appType)."
    return
}

Write-Host "Installing ALCops analyzers (appType=$appType)..."
Write-Host "  Output path: $outputPath"
Write-Host "  Detect using: $env:artifact"

npx --yes '@alcops/core' download `
    --output $outputPath `
    --detect-using $env:artifact `
    --detect-from bc-artifact

if ($LASTEXITCODE -ne 0) {
    throw "ALCops download failed with exit code $LASTEXITCODE"
}

Write-Host "ALCops analyzers installed successfully."

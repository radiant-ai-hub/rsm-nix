#!/usr/bin/env pwsh
# Tests for install/windows-install-rsm-nix.ps1.
#
#   * UNIT: Get-WslDistroPlan -- the pure stray-Ubuntu detection -- across a full
#     matrix. Runs everywhere (pwsh on Linux/macOS via nix, and Windows CI).
#   * INTEGRATION: dry-run of the installer, asserting (a) the always-reboot
#     policy in the missing-WSL path and (b) the stray-Ubuntu preview/skip. The
#     full dry run only runs cleanly on Windows, so those blocks are gated on
#     $IsWindows; the unit matrix is the cross-platform gate.
#
# No Pester dependency: a tiny assert harness, non-zero exit on any failure.

$ErrorActionPreference = "Stop"
$script:Failures = 0
$script:Passed = 0

function Assert-Equal {
    param($Expected, $Actual, [string]$Label)
    $e = ($Expected | Out-String).Trim()
    $a = ($Actual   | Out-String).Trim()
    if ($e -eq $a) { $script:Passed++; Write-Host "  ok   $Label" }
    else {
        $script:Failures++
        Write-Host "  FAIL $Label" -ForegroundColor Red
        Write-Host "       expected: [$e]" -ForegroundColor Red
        Write-Host "       actual:   [$a]" -ForegroundColor Red
    }
}
function Assert-True { param([bool]$Cond, [string]$Label) Assert-Equal $true $Cond $Label }
function Assert-Contains {
    param([string]$Haystack, [string]$Needle, [string]$Label)
    if ($Haystack -match [regex]::Escape($Needle)) { $script:Passed++; Write-Host "  ok   $Label" }
    else { $script:Failures++; Write-Host "  FAIL $Label (missing: '$Needle')" -ForegroundColor Red }
}
function Assert-NotContains {
    param([string]$Haystack, [string]$Needle, [string]$Label)
    if ($Haystack -notmatch [regex]::Escape($Needle)) { $script:Passed++; Write-Host "  ok   $Label" }
    else { $script:Failures++; Write-Host "  FAIL $Label (unexpectedly present: '$Needle')" -ForegroundColor Red }
}

$installer = (Resolve-Path (Join-Path $PSScriptRoot "../install/windows-install-rsm-nix.ps1")).Path
$target = "Ubuntu-26.04"

# --- Dot-source the functions WITHOUT running the installer -------------------
$env:RSM_INSTALLER_NOEXEC = "1"
. $installer
$env:RSM_INSTALLER_NOEXEC = $null

Write-Host "== UNIT: Get-WslDistroPlan =="

$p = Get-WslDistroPlan -Installed @() -Target $target
Assert-True (-not $p.TargetInstalled) "empty: target not installed"
Assert-True (-not $p.HasStray)        "empty: no strays"

$p = Get-WslDistroPlan -Installed @("Ubuntu-26.04") -Target $target
Assert-True $p.TargetInstalled        "target-only: target installed"
Assert-True (-not $p.HasStray)        "target-only: no strays"

$p = Get-WslDistroPlan -Installed @("Ubuntu") -Target $target
Assert-True (-not $p.TargetInstalled) "ubuntu-only: target not installed"
Assert-True $p.HasStray               "ubuntu-only: has stray"
Assert-Equal @("Ubuntu") $p.StrayUbuntu "ubuntu-only: stray = Ubuntu"

$p = Get-WslDistroPlan -Installed @("Ubuntu","Ubuntu-26.04") -Target $target
Assert-True $p.TargetInstalled        "both: target installed"
Assert-Equal @("Ubuntu") $p.StrayUbuntu "both: stray = Ubuntu"

$p = Get-WslDistroPlan -Installed @("Ubuntu-24.04","Ubuntu-26.04") -Target $target
Assert-Equal @("Ubuntu-24.04") $p.StrayUbuntu "2404: stray = Ubuntu-24.04"

$p = Get-WslDistroPlan -Installed @("Debian","Ubuntu-26.04") -Target $target
Assert-True (-not $p.HasStray)        "debian: not a stray"

$p = Get-WslDistroPlan -Installed @("docker-desktop","docker-desktop-data","Ubuntu-26.04") -Target $target
Assert-True (-not $p.HasStray)        "docker: not strays"

$p = Get-WslDistroPlan -Installed @("Ubuntu-26.04","Ubuntu-24.04","Ubuntu") -Target $target
Assert-Equal @("Ubuntu-24.04","Ubuntu") $p.StrayUbuntu "multi: two strays, input order"

$p = Get-WslDistroPlan -Installed @("Ubuntu20.04LTS","Ubuntu-26.04") -Target $target
Assert-Equal @("Ubuntu20.04LTS") $p.StrayUbuntu "legacy: Ubuntu20.04LTS is a stray"

$p = Get-WslDistroPlan -Installed @("UbuntuPro","Ubuntu-26.04") -Target $target
Assert-True (-not $p.HasStray)        "UbuntuPro: not a stray (word boundary)"

$p = Get-WslDistroPlan -Installed @(("Ubuntu" + [char]0), " Ubuntu-26.04 ") -Target $target
Assert-True $p.TargetInstalled        "nul/space: target parsed despite NUL+spaces"
Assert-Equal @("Ubuntu") $p.StrayUbuntu "nul/space: stray parsed despite NUL"

$p = Get-WslDistroPlan -Installed @("UBUNTU") -Target $target
Assert-True $p.HasStray               "case: UBUNTU matched case-insensitively"

# --- INTEGRATION (function-level, cross-platform) -----------------------------
# Drive the two changed dry-run code paths directly, bypassing the Windows-only
# early steps (VS Code/winget). The dot-sourced script params are in this scope,
# so setting them here steers the functions.
Write-Host "== INTEGRATION: function-level dry-run (cross-platform) =="
$DryRun = $true
$DistroName = $target
$Force = $false
$SimulateMissingWsl = $false

# (part 3) a stray 'Ubuntu' next to the target is flagged, target reuse noted.
$SimulateInstalledDistros = "Ubuntu,Ubuntu-26.04"
$out = (Install-UbuntuDistro 6>&1 2>&1 | Out-String)
Assert-Contains    $out "Found other Ubuntu" "stray: flags the stray Ubuntu"
Assert-Contains    $out "unregister"         "stray: mentions unregister cleanup"
Assert-Contains    $out "already installed"  "stray: notes target already installed"

# (part 3) Debian + target => no stray flagged (no false positive).
$SimulateInstalledDistros = "Debian,Ubuntu-26.04"
$out = (Install-UbuntuDistro 6>&1 2>&1 | Out-String)
Assert-NotContains $out "Found other Ubuntu" "debian: no false stray"

# (part 2) missing-WSL path enables both features AND announces a reboot.
$SimulateMissingWsl = $true
$SimulateInstalledDistros = ""
$out = (Ensure-WslFeature 6>&1 2>&1 | Out-String)
Assert-Contains    $out "Microsoft-Windows-Subsystem-Linux" "reboot-path: enables WSL feature"
Assert-Contains    $out "VirtualMachinePlatform"            "reboot-path: enables VM Platform"
Assert-Contains    $out "Microsoft.WSL"                     "reboot-path: installs WSL runtime"
Assert-Contains    $out "require a reboot"                  "reboot-path: announces required reboot"
$SimulateMissingWsl = $false

# --- INTEGRATION: dry-run of the whole installer (Windows only) ---------------
function Invoke-InstallerDryRun {
    param([string[]]$ExtraArgs)
    $allArgs = @("-DryRun", "-SkipWorkspaceSetup") + $ExtraArgs
    return (& $installer @allArgs 6>&1 2>&1 | Out-String)
}

if ($IsWindows) {
    Write-Host "== INTEGRATION: dry-run (Windows) =="

    # (part 2) missing-WSL path must enable both features AND announce a reboot.
    $out = Invoke-InstallerDryRun @("-SimulateMissingWsl", "-SimulateInstalledDistros", "Ubuntu-26.04")
    Assert-Contains $out "Microsoft-Windows-Subsystem-Linux" "reboot-path: enables WSL feature"
    Assert-Contains $out "VirtualMachinePlatform"            "reboot-path: enables VM Platform"
    Assert-Contains $out "Microsoft.WSL"                     "reboot-path: installs WSL runtime"
    Assert-Contains $out "require a reboot"                  "reboot-path: announces required reboot"

    # (part 3) a stray 'Ubuntu' alongside the target must be flagged for cleanup.
    $out = Invoke-InstallerDryRun @("-SimulateInstalledDistros", "Ubuntu,Ubuntu-26.04")
    Assert-Contains    $out "Found other Ubuntu"  "stray: flags the stray Ubuntu"
    Assert-Contains    $out "unregister"          "stray: mentions unregister cleanup"
    Assert-Contains    $out "already installed"   "stray: notes target already installed"

    # (part 3) Debian + target => NO stray flagged (no false positive).
    $out = Invoke-InstallerDryRun @("-SimulateInstalledDistros", "Debian,Ubuntu-26.04")
    Assert-NotContains $out "Found other Ubuntu"  "debian: no false stray"
} else {
    Write-Host "== INTEGRATION: dry-run skipped (not Windows; runs in CI) =="
}

Write-Host ""
Write-Host "Passed: $script:Passed   Failed: $script:Failures"
if ($script:Failures -gt 0) { exit 1 }
Write-Host "ALL TESTS PASSED" -ForegroundColor Green
exit 0

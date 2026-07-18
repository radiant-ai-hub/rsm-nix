# RSM-MSBA Nix development environment installer for Windows.
#
# Run from PowerShell:
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\install\windows-install-rsm-nix.ps1
# or:
#   powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr -useb https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/windows-install-rsm-nix.ps1 | iex"
#
# The development environment itself runs in Ubuntu 26.04 on WSL2. Windows is
# used for VS Code and the WSL integration only.

[CmdletBinding()]
param(
    [string]$RepoUrl = "https://github.com/radiant-ai-hub/rsm-nix.git",
    [string]$WorkspacePath = "~/rsm-msba",
    [string]$DistroName = "Ubuntu-26.04",
    [string]$WslUser = "",
    [switch]$Force,
    [switch]$SkipVSCode,
    [switch]$SkipWorkspaceSetup,
    [switch]$DryRun,
    # Test hook: force the "wsl.exe is missing" install path even when wsl.exe
    # exists, so CI can regression-test WSL installation on a runner that already
    # has WSL. Not for normal use.
    [switch]$SimulateMissingWsl
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# WSL's informational output (--list, --status, --help) is UTF-16 by default,
# which corrupts text matching from PowerShell -- e.g. an available distro like
# Ubuntu-26.04 wrongly looking "absent", sending the installer down a fragile
# fallback path. WSL_UTF8=1 makes WSL emit UTF-8 so parsing is reliable. It is
# honored by WSL 0.64+ (every current Windows 11 build).
$env:WSL_UTF8 = "1"

# Fallback extension list, used only if vscode/extensions.txt can't be fetched
# (offline, etc.). The curated list lives in vscode/extensions.txt in the repo.
$VSCodeExtensions = @(
    "ms-vscode-remote.remote-wsl",
    "ms-python.python",
    "ms-toolsai.jupyter",
    "quarto.quarto",
    "pinage404.nix-extension-pack"
)

$UbuntuDistributionInfoUrl = "https://raw.githubusercontent.com/microsoft/WSL/master/distributions/DistributionInfo.json"

function Get-ExtensionsUrl {
    # Raw URL of vscode/extensions.txt in the repo being installed from.
    # Extensions are installed before the repo is cloned (and on Windows the
    # clone lives inside WSL), so the list is fetched over HTTP.
    if ($RepoUrl -match '^https://github\.com/(.+?)(\.git)?$') {
        return "https://raw.githubusercontent.com/$($Matches[1])/main/vscode/extensions.txt"
    }
    return "https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/vscode/extensions.txt"
}

function Get-DesiredVSCodeExtensions {
    try {
        $text = (Invoke-WebRequest -Uri (Get-ExtensionsUrl) -UseBasicParsing).Content
        $list = @(
            ($text -replace "`0", "") -split "`r?`n" |
                ForEach-Object { $_.Trim() } |
                Where-Object { $_ -and -not $_.StartsWith("#") }
        )
        if ($list.Count -gt 0) {
            return $list
        }
    } catch {
        Write-Detail "Could not fetch extensions.txt ($($_.Exception.Message)); using the built-in list."
    }
    return $VSCodeExtensions
}

function Write-BlankLine {
    Write-Host ""
}

function Write-Section {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Detail {
    param([string]$Message)
    Write-Host "  $Message" -ForegroundColor Gray
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-SafeWslUser {
    param([string]$Candidate)

    if (-not $Candidate) {
        $Candidate = if ($env:USERNAME) { $env:USERNAME } else { "rsm" }
    }

    $safe = $Candidate.ToLowerInvariant() -replace "[^a-z0-9_-]", ""
    if ($safe -notmatch "^[a-z_]") {
        $safe = "rsm$safe"
    }
    if ($safe.Length -gt 32) {
        $safe = $safe.Substring(0, 32)
    }
    if (-not $safe) {
        $safe = "rsm"
    }

    return $safe
}

function Get-WindowsArchitecture {
    $arch = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
    switch -Regex ($arch.ToUpperInvariant()) {
        "^ARM64$" { return "arm64" }
        "^AMD64$" { return "amd64" }
        default { throw "Unsupported Windows architecture for this installer: $arch" }
    }
}

function Invoke-CheckedCommand {
    param(
        [string]$Program,
        [string[]]$Arguments,
        [string]$FailureMessage
    )

    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw $FailureMessage
    }
}

function Get-CommandPathOrNull {
    param([string]$Name)

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    return $null
}

function Get-InstalledWslDistros {
    $output = & wsl.exe --list --quiet 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $output) {
        return @()
    }

    return @(
        $output |
            ForEach-Object { ($_ -replace "`0", "").Trim() } |
            Where-Object { $_ }
    )
}

function Get-WslDistroVersion {
    param([string]$Name)

    # `wsl -l -v` columns are NAME / STATE / VERSION (the default distro carries
    # a leading '*'). Returns "1", "2", or $null when it can't be determined.
    $lines = ((& wsl.exe --list --verbose 2>$null | Out-String) -replace "`0", "") -split "`r?`n"
    foreach ($line in $lines) {
        $fields = ($line -replace "^\*", "").Trim() -split "\s+"
        if ($fields.Count -ge 3 -and $fields[0] -eq $Name) {
            return $fields[-1]
        }
    }
    return $null
}

function Set-WslDistroToV2 {
    param([string]$Name)

    # Distros from `wsl --install` are already WSL2 (we set the default version
    # to 2 before installing), so only CONVERT when the distro is actually v1.
    # Calling `--set-version <name> 2` on an already-v2 distro fails with
    # WSL_E_VM_MODE_INVALID_STATE, so never force it.
    $version = Get-WslDistroVersion -Name $Name
    if ($version -eq "2") {
        Write-Detail "$Name is already WSL2."
        return
    }
    if ($version -eq "1") {
        Write-Detail "Converting $Name to WSL2..."
        & wsl.exe --set-version $Name 2
        if ($LASTEXITCODE -ne 0) {
            throw "Could not convert $Name to WSL2."
        }
        return
    }
    Write-Detail "Could not read $Name's WSL version; assuming WSL2 (default version is 2)."
}

function Set-WslDefaultDistro {
    param([string]$Name)

    # Make this the default distro so plain `wsl` and VS Code's 'Connect to WSL'
    # target it. Non-fatal: the installer always addresses the distro by name.
    & wsl.exe --set-default $Name 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Detail "$Name set as the default WSL distro."
    }
}

function Test-WslOnlineDistroAvailable {
    param([string]$Name)

    # Strip any stray NULs (UTF-16 leftovers) before matching, mirroring
    # Get-InstalledWslDistros, in case WSL_UTF8 is not honored on this build.
    $online = (& wsl.exe --list --online 2>$null | Out-String) -replace "`0", ""
    if ($LASTEXITCODE -ne 0) {
        return $false
    }

    return $online -match "(?m)^\s*$([regex]::Escape($Name))\s"
}

function Get-UbuntuWslImageInfo {
    param([string]$Name)

    $arch = Get-WindowsArchitecture
    $json = Invoke-RestMethod -Uri $UbuntuDistributionInfoUrl
    $ubuntuEntries = @($json.ModernDistributions.Ubuntu)
    $entry = $ubuntuEntries | Where-Object { $_.Name -eq $Name } | Select-Object -First 1
    if (-not $entry) {
        throw "Could not find '$Name' in Microsoft WSL distribution metadata."
    }

    $asset = if ($arch -eq "arm64") { $entry.Arm64Url } else { $entry.Amd64Url }
    if (-not $asset -or -not $asset.Url -or -not $asset.Sha256) {
        throw "Microsoft WSL metadata for '$Name' does not include a $arch image."
    }

    return [pscustomobject]@{
        Url = [string]$asset.Url
        Sha256 = ([string]$asset.Sha256).ToLowerInvariant()
        Architecture = $arch
    }
}

function Find-VSCodeCommand {
    $candidates = @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.exe",
        "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd",
        "$env:ProgramFiles\Microsoft VS Code\bin\code.exe",
        "${env:ProgramFiles(x86)}\Microsoft VS Code\bin\code.cmd",
        "${env:ProgramFiles(x86)}\Microsoft VS Code\bin\code.exe"
    )

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) {
            return $candidate
        }
    }

    $command = Get-Command code -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    return $null
}

function Install-VSCodeAndExtensions {
    if ($SkipVSCode) {
        Write-Detail "Skipping VS Code setup."
        return
    }

    Write-Section "Step 1: Checking Visual Studio Code..."

    if (-not (Get-CommandPathOrNull "winget.exe")) {
        throw "winget is required to install VS Code. Install App Installer from Microsoft Store, then rerun."
    }

    if ($DryRun) {
        Write-Detail "[dry-run] Verifying winget can resolve Microsoft.VisualStudioCode..."
        $package = winget show --exact --id Microsoft.VisualStudioCode --accept-source-agreements | Out-String
        if ($package -notmatch "Microsoft\.VisualStudioCode") {
            throw "winget could not resolve Microsoft.VisualStudioCode."
        }
        $extensions = Get-DesiredVSCodeExtensions
        Write-Detail "[dry-run] Would install $($extensions.Count) VS Code extensions from extensions.txt."
        Write-BlankLine
        return
    }

    $installed = $false
    try {
        $list = winget list --exact --id Microsoft.VisualStudioCode --accept-source-agreements 2>$null | Out-String
        $installed = $list -match "Microsoft\.VisualStudioCode"
    } catch {
        $installed = $false
    }

    if ($installed) {
        Write-Detail "VS Code already installed."
    } else {
        Write-Detail "Installing VS Code with winget..."
        Invoke-CheckedCommand "winget.exe" @(
            "install",
            "--exact",
            "--id", "Microsoft.VisualStudioCode",
            "--source", "winget",
            "--scope", "user",
            "--accept-package-agreements",
            "--accept-source-agreements",
            "--silent",
            "--disable-interactivity"
        ) "VS Code installation failed."
    }

    $codeCommand = Find-VSCodeCommand
    if (-not $codeCommand) {
        throw "VS Code installed, but the 'code' command was not found in expected locations."
    }

    $extensions = Get-DesiredVSCodeExtensions
    Write-Detail "Installing $($extensions.Count) VS Code extensions..."
    foreach ($extension in $extensions) {
        Write-Detail "  $extension"
        & $codeCommand --install-extension $extension --force | Out-Host
        if ($LASTEXITCODE -ne 0) {
            Write-Detail "  could not install $extension; continuing."
        }
    }

    Write-BlankLine
}

function Install-NerdFont {
    # powerlevel10k draws its icons with a Nerd Font. The terminal is rendered
    # by the Windows-side editor/terminal, so the font must be installed on
    # Windows (not in WSL). Installs MesloLGS NF (p10k's recommended font) for
    # the current user -- no admin needed. Non-fatal: a font hiccup must never
    # block the environment setup.
    Write-Section "Step 1b: Installing the MesloLGS Nerd Font..."

    $fontFiles = @(
        "MesloLGS NF Regular.ttf",
        "MesloLGS NF Bold.ttf",
        "MesloLGS NF Italic.ttf",
        "MesloLGS NF Bold Italic.ttf"
    )
    $baseUrl = "https://github.com/romkatv/powerlevel10k-media/raw/master"

    if ($DryRun) {
        foreach ($fontFile in $fontFiles) {
            Write-Detail "[dry-run] Would install font: $fontFile"
        }
        Write-BlankLine
        return
    }

    $fontsDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
    $regPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
    New-Item -ItemType Directory -Path $fontsDir -Force | Out-Null
    if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }

    foreach ($fontFile in $fontFiles) {
        try {
            $dest = Join-Path $fontsDir $fontFile
            $regName = ($fontFile -replace "\.ttf$", "") + " (TrueType)"
            if (Test-Path $dest) {
                Write-Detail "Font already present: $fontFile"
            } else {
                $url = "$baseUrl/$([uri]::EscapeDataString($fontFile))"
                Write-Detail "Downloading $fontFile..."
                Invoke-WebRequest -Uri $url -OutFile $dest
            }
            New-ItemProperty -Path $regPath -Name $regName -Value $dest -PropertyType String -Force | Out-Null
        } catch {
            Write-Detail "Could not install $fontFile ($($_.Exception.Message)); continuing."
        }
    }

    Write-Detail "MesloLGS NF installed. VS Code's terminal is set to it automatically;"
    Write-Detail "for Windows Terminal, pick 'MesloLGS NF' under Settings > Appearance > Font."
    Write-BlankLine
}

function Install-Tailscale {
    # Tailscale lets students reach the MSBA server from any network (incl.
    # UCSD-Protected) without the campus VPN. We install the app here; the
    # student still has to sign in (their own account) and accept the
    # instructor's share link -- those are interactive and can't be automated.
    Write-Section "Step 1c: Installing Tailscale..."

    if ($DryRun) {
        Write-Detail "[dry-run] Would install Tailscale (winget id Tailscale.Tailscale)."
        Write-BlankLine
        return
    }

    if (-not (Get-CommandPathOrNull "winget.exe")) {
        Write-Detail "winget not found; skipping Tailscale (install from https://tailscale.com/download/windows)."
        Write-BlankLine
        return
    }

    $installed = $false
    try {
        $list = winget list --exact --id Tailscale.Tailscale --accept-source-agreements 2>$null | Out-String
        $installed = $list -match "Tailscale\.Tailscale"
    } catch {
        $installed = $false
    }

    if ($installed) {
        Write-Detail "Tailscale already installed."
    } else {
        Write-Detail "Installing Tailscale with winget (you may see a Windows admin prompt)..."
        & winget.exe install --exact --id Tailscale.Tailscale --source winget `
            --accept-package-agreements --accept-source-agreements --silent | Out-Host
        if ($LASTEXITCODE -ne 0) {
            Write-Detail "Tailscale did not install automatically -- install it from https://tailscale.com/download/windows"
        }
    }

    Write-Detail "Tailscale, once: open it, sign in with your OWN account, then open the"
    Write-Detail "instructor's share link and click Accept to reach the server."
    Write-BlankLine
}

function Assert-WslPrerequisites {
    # WSL2 needs a recent-enough Windows build and hardware virtualization.
    # Neither is something this script can install/toggle, so surface exactly
    # what the user must do -- a Windows Update/upgrade vs a BIOS/UEFI setting --
    # instead of letting them hit a cryptic DISM or "WSL won't start" failure.
    $build = 0
    try {
        $build = [int](Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction Stop).CurrentBuildNumber
    } catch {}
    if ($build -gt 0 -and $build -lt 19041) {
        throw "This Windows build ($build) is too old for WSL2, which needs build 19041 (Windows 10, version 2004) or Windows 11. Fix: open Settings > Windows Update, install all updates (or upgrade Windows), reboot, then rerun this installer."
    }

    $virtEnabled = $null
    $hypervisor = $null
    try { $virtEnabled = (Get-CimInstance -ClassName Win32_Processor -ErrorAction Stop | Select-Object -First 1).VirtualizationFirmwareEnabled } catch {}
    try { $hypervisor = (Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop).HypervisorPresent } catch {}
    if (($hypervisor -eq $false) -and ($virtEnabled -eq $false)) {
        Write-Host "  WARNING: hardware virtualization appears disabled in firmware." -ForegroundColor Yellow
        Write-Host "  WSL2 will not start until it is enabled. Reboot into your BIOS/UEFI and" -ForegroundColor Yellow
        Write-Host "  turn on Intel VT-x / AMD-V (often labeled 'SVM' or 'Virtualization" -ForegroundColor Yellow
        Write-Host "  Technology'), then rerun this installer." -ForegroundColor Yellow
    }
}

function Enable-WslOptionalFeatures {
    # Enable the two Windows features WSL2 needs. This is the fallback for builds
    # where wsl.exe isn't present yet (so `wsl --install` can't run). DISM returns
    # 3010 (ERROR_SUCCESS_REBOOT_REQUIRED) when it staged changes that need a
    # reboot -- treat that as success-with-reboot, not failure.
    foreach ($feature in @("Microsoft-Windows-Subsystem-Linux", "VirtualMachinePlatform")) {
        Write-Detail "Enabling Windows feature: $feature ..."
        & dism.exe /online /enable-feature /featurename:$feature /all /norestart | Out-Host
        if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne 3010) {
            throw "Failed to enable Windows feature '$feature' (dism exit $LASTEXITCODE). Enable it manually, reboot, and rerun this installer."
        }
    }
}

function Stop-ForReboot {
    param([string]$Reason)
    # A reboot-required stop is a normal step, not a failure. A plain script can't
    # continue across a reboot on its own, so we offer to reboot now (only when
    # genuinely interactive -- never headless/CI) and tell the user to rerun this
    # installer afterward; it is idempotent and resumes from where it left off.
    Write-BlankLine
    Write-Host "============================================================" -ForegroundColor Yellow
    Write-Host " $Reason" -ForegroundColor Yellow
    Write-Host " Windows must reboot to finish enabling WSL. After it restarts," -ForegroundColor Yellow
    Write-Host " run this installer again to continue -- it resumes automatically." -ForegroundColor Yellow
    Write-Host "============================================================" -ForegroundColor Yellow
    Write-BlankLine

    # Only prompt/auto-reboot for a real interactive console. A redirected or
    # non-interactive session (piped, CI, scheduled) must never reboot on its own.
    if ([Environment]::UserInteractive -and -not [Console]::IsInputRedirected) {
        $answer = Read-Host "Reboot now? [Y/n]"
        if ([string]::IsNullOrWhiteSpace($answer) -or $answer -match '^(y|yes)$') {
            Write-Host "Save any open work -- rebooting now..." -ForegroundColor Yellow
            Restart-Computer -Force
            exit 0
        }
        Write-Host "OK -- reboot when you're ready, then rerun this installer to continue." -ForegroundColor Yellow
    } else {
        Write-Host "Reboot Windows, then rerun this installer to continue." -ForegroundColor Yellow
    }
    exit 0
}

function Install-WslRuntime {
    # Install the actual WSL runtime PACKAGE -- not just the Windows features. On
    # Windows 11 the runtime is an app delivered by winget/Store; enabling the
    # optional features alone leaves every wsl command reporting "...is not
    # installed". `winget install Microsoft.WSL` reliably installs it, whereas the
    # inbox `wsl.exe --install` stub can loop ("...is not installed. You can
    # install by running 'wsl.exe --install'.") once the features are enabled.
    # Prefer winget; fall back to wsl.exe --install.
    if (Get-CommandPathOrNull "winget.exe") {
        Write-Detail "Installing the WSL runtime (winget Microsoft.WSL)..."
        & winget.exe install --id Microsoft.WSL --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>&1 | Out-Host
        if ($LASTEXITCODE -eq 0) { return }
        Write-Detail "winget install did not succeed (exit $LASTEXITCODE); trying 'wsl --install'."
    } else {
        Write-Detail "winget not found; using 'wsl --install' to fetch the WSL runtime."
    }
    if (Get-CommandPathOrNull "wsl.exe") {
        & wsl.exe --install --no-distribution --web-download 2>&1 | Out-Host
    }
}

function Install-WslPlatform {
    # Enable the WSL Windows features AND install the WSL runtime package, then
    # continue if WSL works now, or STOP for a reboot if it doesn't. The features
    # being Enabled is NOT sufficient -- the runtime (Microsoft.WSL) must be
    # present too. If the features were only just enabled, VirtualMachinePlatform
    # needs a reboot to activate before WSL can run.
    if (-not (Test-IsAdministrator)) {
        throw "WSL is not installed, and installing it requires Administrator. Right-click PowerShell, choose 'Run as Administrator', then rerun this installer."
    }
    Assert-WslPrerequisites
    Write-Detail "Enabling the WSL Windows features..."
    Enable-WslOptionalFeatures
    Install-WslRuntime

    # Continue without a disruptive reboot if WSL is functional now (features were
    # already active); otherwise the freshly enabled VirtualMachinePlatform needs
    # a reboot to activate.
    & wsl.exe --shutdown 2>$null
    if (Test-WslReady) {
        Write-Detail "WSL is installed and functional."
        return
    }
    Stop-ForReboot "WSL has been installed. Reboot to finish enabling it, then rerun this installer to continue."
}

function Test-WslReady {
    # Is the WSL RUNTIME installed and working? This is the authoritative check --
    # NOT the Windows feature state. On Windows 11 the features can be 'Enabled'
    # while the runtime package (Microsoft.WSL) is absent, in which case every wsl
    # command exits nonzero and prints "...is not installed". wsl.exe also ships
    # as a stub even when nothing is installed, so its mere presence proves
    # nothing, and its output is UTF-16 (NUL-separated). So run wsl --status,
    # strip NULs, and require a clean, installed result.
    if (-not (Get-CommandPathOrNull "wsl.exe")) {
        return $false
    }
    try {
        $env:WSL_UTF8 = "1"
        $raw = ((& wsl.exe --status 2>&1 | Out-String) -replace "`0", "")
        return (($LASTEXITCODE -eq 0) -and
                ($raw.Trim().Length -gt 0) -and
                ($raw -notmatch 'not installed'))
    } catch {
        return $false
    }
}

function Ensure-WslFeature {
    Write-Section "Step 2: Checking WSL2..."

    if ($DryRun) {
        if ($SimulateMissingWsl -or -not (Get-CommandPathOrNull "wsl.exe")) {
            Write-Detail "[dry-run] WSL not installed; would install it:"
            Write-Detail "[dry-run] Would run: dism /online /enable-feature Microsoft-Windows-Subsystem-Linux /all /norestart"
            Write-Detail "[dry-run] Would run: dism /online /enable-feature VirtualMachinePlatform /all /norestart"
            Write-Detail "[dry-run] Would run: winget install --id Microsoft.WSL (fallback: wsl --install --no-distribution)"
        } else {
            Write-Detail "[dry-run] Would verify WSL readiness by running wsl --status."
            Write-Detail "[dry-run] Would run: wsl --update --web-download"
            Write-Detail "[dry-run] Would run: wsl --set-default-version 2"
        }
        Write-BlankLine
        return
    }

    # Authoritative readiness check -- NOT just "does wsl.exe exist" (the stub
    # always exists) nor a fragile parse of wsl --status.
    if ($SimulateMissingWsl -or -not (Test-WslReady)) {
        Install-WslPlatform   # enables the features, then STOPS for a reboot
    } else {
        Write-Detail "WSL platform is enabled."
    }

    Write-Detail "Updating WSL..."
    & wsl.exe --update --web-download | Out-Host
    if ($LASTEXITCODE -ne 0) {
        Write-Detail "WSL update did not complete; continuing with the installed WSL version."
    }

    Invoke-CheckedCommand "wsl.exe" @("--set-default-version", "2") "Could not set WSL2 as the default WSL version."
    Write-BlankLine
}

function Download-UbuntuWslImage {
    param([object]$ImageInfo)

    $cacheDir = Join-Path $env:TEMP "rsm-nix-wsl"
    New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
    $imagePath = Join-Path $cacheDir (Split-Path -Leaf $ImageInfo.Url)

    # Drop any stale/partial cached copy so we fetch cleanly.
    if (Test-Path $imagePath) {
        $cachedHash = (Get-FileHash -Path $imagePath -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($cachedHash -ne $ImageInfo.Sha256) {
            Remove-Item -Path $imagePath -Force -ErrorAction SilentlyContinue
        }
    }

    if (-not (Test-Path $imagePath)) {
        Write-Detail "Downloading the Ubuntu WSL image (~hundreds of MB) for $($ImageInfo.Architecture)..."
        # Prefer curl.exe (bundled with Windows 10/11): far faster and more
        # robust than Invoke-WebRequest for large files. --speed-time aborts a
        # stalled transfer (the "hangs at 0%" case) so --retry can restart it.
        $curl = Get-CommandPathOrNull "curl.exe"
        if ($curl) {
            & $curl -L --fail --retry 5 --retry-all-errors --retry-delay 3 `
                --speed-limit 2048 --speed-time 30 -o $imagePath $ImageInfo.Url
            if ($LASTEXITCODE -ne 0) {
                Remove-Item -Path $imagePath -Force -ErrorAction SilentlyContinue
                throw "Downloading the Ubuntu image failed (curl exit $LASTEXITCODE). Check your network / VPN / proxy and rerun."
            }
        } else {
            Invoke-WebRequest -Uri $ImageInfo.Url -OutFile $imagePath
        }
    }

    $actualHash = (Get-FileHash -Path $imagePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualHash -ne $ImageInfo.Sha256) {
        Remove-Item -Path $imagePath -Force -ErrorAction SilentlyContinue
        throw "Ubuntu WSL image checksum mismatch. Expected $($ImageInfo.Sha256), got $actualHash."
    }

    return $imagePath
}

function Install-UbuntuDistro {
    Write-Section "Step 3: Checking Ubuntu 26.04 WSL distro..."

    if ($DryRun) {
        if (Test-WslOnlineDistroAvailable -Name $DistroName) {
            Write-Detail "[dry-run] $DistroName is available from 'wsl --list --online'."
        } else {
            $image = Get-UbuntuWslImageInfo -Name $DistroName
            Write-Detail "[dry-run] $DistroName was not listed online; resolved fallback image:"
            Write-Detail "[dry-run] $($image.Url)"
        }
        Write-BlankLine
        return
    }

    $installedDistros = Get-InstalledWslDistros
    if ($installedDistros -contains $DistroName) {
        if ($Force) {
            Write-Detail "Removing existing $DistroName because -Force was supplied."
            Invoke-CheckedCommand "wsl.exe" @("--unregister", $DistroName) "Could not unregister existing $DistroName."
        } else {
            Write-Detail "$DistroName is already installed. Reusing it."
            Set-WslDistroToV2 -Name $DistroName
            Set-WslDefaultDistro -Name $DistroName
            Write-BlankLine
            return
        }
    }

    # Try the plain `wsl --install -d <name>` first -- it's what works
    # interactively (incl. Ubuntu-26.04 on Windows ARM) and lets WSL pick the
    # best source. If it fails, force a web download; only if that also fails do
    # we fetch the .wsl image directly (via curl, which is more robust than
    # WSL's own downloader when it times out / stalls).
    Write-Detail "Installing $DistroName via 'wsl --install -d'..."
    & wsl.exe --install -d $DistroName --no-launch
    if ($LASTEXITCODE -ne 0) {
        Write-Detail "Retrying with --web-download..."
        & wsl.exe --install -d $DistroName --web-download --no-launch
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Detail "Online install did not succeed; downloading the Ubuntu .wsl image directly..."
        $image = Get-UbuntuWslImageInfo -Name $DistroName
        $imagePath = Download-UbuntuWslImage -ImageInfo $image
        $help = & wsl.exe --help | Out-String
        if ($help -notmatch "--from-file") {
            throw "Could not install $DistroName, and this WSL version cannot install .wsl files. Run 'wsl --update --web-download', reboot, and rerun."
        }

        Write-Detail "Installing $DistroName from Ubuntu .wsl image..."
        & wsl.exe --install --from-file $imagePath --name $DistroName --no-launch
        if ($LASTEXITCODE -ne 0) {
            Write-Detail "Retrying without --name for older WSL builds..."
            & wsl.exe --install --from-file $imagePath --no-launch
        }
        if ($LASTEXITCODE -ne 0) {
            throw "Installing $DistroName from the .wsl image failed."
        }
    }

    Set-WslDistroToV2 -Name $DistroName
    Set-WslDefaultDistro -Name $DistroName
    Write-BlankLine
}

function Invoke-WslBash {
    param(
        [string]$User,
        [string]$Script,
        [string[]]$Arguments = @(),
        [string]$Description = "WSL command"
    )

    if ($DryRun) {
        Write-Detail "[dry-run] Would run in $DistroName as ${User}: $Description"
        return
    }

    # Transport the script as base64 instead of piping it to bash's stdin.
    # Piping is fragile: PowerShell/wsl.exe stdin handling can reintroduce CRLF,
    # which breaks heredocs ("here-document ... wanted 'EOF'") and appends stray
    # \r to paths ("No such file or directory"). base64 round-trips the exact LF
    # bytes, and running the decoded script from a pipe (not via the outer
    # stdin) keeps the heredoc/stdin behaviour clean.
    $normalized = $Script -replace "`r`n", "`n"
    $b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($normalized))
    $argString = ($Arguments | ForEach-Object { "'" + ($_ -replace "'", "'\''") + "'" }) -join " "
    $remote = "printf '%s' '$b64' | base64 -d | bash -s -- $argString"

    & wsl.exe -d $DistroName --user $User -- bash -c $remote
    if ($LASTEXITCODE -ne 0) {
        Write-BlankLine
        Write-Host "  $Description failed (exit $LASTEXITCODE)." -ForegroundColor Red
        Write-Host "  The real error is in the WSL output above (look for a red 'FAIL' line)." -ForegroundColor Yellow
        Write-Host "  To reproduce it with full detail, open a WSL terminal and run:" -ForegroundColor Yellow
        Write-Host "      wsl -d $DistroName" -ForegroundColor Yellow
        Write-Host "      nix develop ~/rsm-nix -c rsm-setup" -ForegroundColor Yellow
        throw "$Description failed (exit $LASTEXITCODE) - see the WSL output above."
    }
}

function Initialize-WslDistro {
    if ($DryRun) {
        return
    }

    # A freshly registered distro -- especially after an unregister/reinstall, or
    # one installed with --no-launch -- often can't run a command on the very
    # first try: "Wsl/Service/CreateInstance/E_UNEXPECTED". Reset the WSL service
    # and warm the distro up (as root, which bypasses the interactive first-run)
    # with a few retries before we configure it.
    Write-Section "Preparing $DistroName for first use..."
    & wsl.exe --shutdown 2>$null
    Start-Sleep -Seconds 2

    for ($attempt = 1; $attempt -le 8; $attempt++) {
        & wsl.exe -d $DistroName --user root -- true 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Detail "$DistroName is ready."
            Write-BlankLine
            return
        }
        Write-Detail "Waiting for $DistroName to become ready (attempt $attempt)..."
        if ($attempt -eq 4) {
            & wsl.exe --shutdown 2>$null
        }
        Start-Sleep -Seconds 3
    }

    throw "Could not start $DistroName (Wsl/Service/CreateInstance/E_UNEXPECTED). Run 'wsl --shutdown' (and reboot Windows if it persists), then rerun this installer."
}

function Configure-UbuntuUser {
    Write-Section "Step 4: Configuring Ubuntu user..."

    $setupScript = @'
set -euo pipefail
wsl_user="$1"

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  bash \
  ca-certificates \
  curl \
  git \
  sudo \
  xz-utils \
  zsh

if ! id -u "$wsl_user" >/dev/null 2>&1; then
  useradd -m -s "$(command -v zsh)" "$wsl_user"
fi

usermod -aG sudo "$wsl_user"
# Make zsh the login shell so VS Code, Windows Terminal, and `wsl` all start in
# it (the oh-my-zsh/powerlevel10k shell loads on entering ~/rsm-msba). Mirrors
# the NixOS server, where zsh is already the login shell.
zsh_path="$(command -v zsh)"
chsh -s "$zsh_path" "$wsl_user" 2>/dev/null || usermod -s "$zsh_path" "$wsl_user" || true
printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$wsl_user" >"/etc/sudoers.d/90-rsm-nix-$wsl_user"
chmod 0440 "/etc/sudoers.d/90-rsm-nix-$wsl_user"

# appendWindowsPath=false keeps the Windows PATH out of WSL so a Windows
# node/npm/claude (e.g. nvm4w under /mnt/c) can't shadow the WSL-native ones and
# break `claude`. It does NOT affect /mnt/c file access (that is [automount],
# left enabled). `code` still works in VS Code's WSL terminal (server-injected).
printf '%s\n' '[user]' "default=$wsl_user" '' '[boot]' 'systemd=true' '' '[interop]' 'appendWindowsPath=false' >/etc/wsl.conf
'@

    Invoke-WslBash -User "root" -Script $setupScript -Arguments @($script:EffectiveWslUser) -Description "Ubuntu base configuration"

    if (-not $DryRun) {
        & wsl.exe --terminate $DistroName 2>$null
    }
    Write-BlankLine
}

function Install-RsmWorkspace {
    if ($SkipWorkspaceSetup) {
        Write-Detail "Skipping WSL workspace setup."
        return
    }

    Write-Section "Step 5: Installing Nix and RSM workspace inside WSL..."

    $workspaceScript = @'
set -euo pipefail
repo_url="$1"
workspace="$2"
flake="$HOME/rsm-nix"   # the flake repo (git pull to update)

case "$workspace" in
  "~") workspace="$HOME" ;;
  "~/"*) workspace="$HOME/${workspace#"~/"}" ;;
esac

if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "==> Installing Nix (Determinate); this is usually quick (~1-2 min)..."
  # timeout bounds the whole pipeline so a stalled download / unready systemd
  # fails loudly instead of hanging the installer forever.
  if ! timeout 900 sh -c "curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm"; then
    echo "FAIL: Nix install stalled or failed (network/proxy, or WSL systemd not ready)." >&2
    echo "      From Windows run 'wsl --shutdown', then rerun this installer." >&2
    exit 1
  fi
fi

if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "Nix was installed, but the nix command is not active in this shell." >&2
  exit 1
fi

# The Nix daemon must actually respond, else EVERY later `nix` call blocks
# forever with no output -- the classic "install hung" symptom, usually because
# WSL systemd didn't come up so nix-daemon never started. Probe it with a hard
# timeout and fail fast with a fix instead of hanging.
echo "==> Verifying the Nix daemon is responding..."
if ! timeout 120 nix store ping >/dev/null 2>&1; then
  echo "FAIL: the Nix daemon is not responding (WSL systemd likely did not start)." >&2
  echo "      From Windows run 'wsl --shutdown', then rerun this installer." >&2
  exit 1
fi

# `nix profile install` is a deprecated alias for `nix profile add`; pick
# whichever the installed Nix supports (Determinate Nix is recent enough).
if nix profile add --help >/dev/null 2>&1; then
  nix_profile_add="add"
else
  nix_profile_add="install"
fi

if ! command -v direnv >/dev/null 2>&1; then
  nix profile "$nix_profile_add" nixpkgs#direnv
fi

if [ ! -e "$HOME/.nix-profile/share/nix-direnv/direnvrc" ]; then
  nix profile "$nix_profile_add" nixpkgs#nix-direnv
fi

mkdir -p "$HOME/.config/direnv"
touch "$HOME/.config/direnv/direnvrc"
if ! grep -Fqx 'source ~/.nix-profile/share/nix-direnv/direnvrc' "$HOME/.config/direnv/direnvrc"; then
  printf '%s\n' 'source ~/.nix-profile/share/nix-direnv/direnvrc' >>"$HOME/.config/direnv/direnvrc"
fi

touch "$HOME/.bashrc"
if ! grep -Fqx 'eval "$(direnv hook bash)"' "$HOME/.bashrc"; then
  printf '\n%s\n' 'eval "$(direnv hook bash)"' >>"$HOME/.bashrc"
fi

# zsh is the login shell (set in step 4). Wire up direnv for zsh and auto-load
# the oh-my-zsh/powerlevel10k shell on entering ~/rsm-msba, so Windows Terminal
# and plain `wsl` behave like the VS Code terminal (which loads it via ZDOTDIR).
touch "$HOME/.zshrc"
if ! grep -Fq '# >>> rsm-msba (managed) >>>' "$HOME/.zshrc"; then
  cat >>"$HOME/.zshrc" <<'ZRC'

# >>> rsm-msba (managed) >>>
# Nix on PATH (safety net; harmless if the system zsh config already does this).
[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && \
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
# direnv: load the per-folder rsm-msba Python environment automatically.
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
# Load the full oh-my-zsh + powerlevel10k shell when you enter ~/rsm-msba.
# (In VS Code the ZDOTDIR workspace setting loads it at startup instead.)
_rsm_zsh_load() {
  local zd="$HOME/rsm-msba/.rsm-msba/zsh"
  if [[ -z ${_RSM_ZSH_LOADED:-} && -f "$zd/.zshrc" && ( $PWD == "$HOME/rsm-msba" || $PWD == "$HOME/rsm-msba"/* ) ]]; then
    export _RSM_ZSH_LOADED=1 ZDOTDIR="$zd"
    source "$zd/.zshrc"
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _rsm_zsh_load
_rsm_zsh_load
# <<< rsm-msba (managed) <<<
ZRC
fi

if [ -e "$flake" ] && [ ! -d "$flake/.git" ]; then
  echo "Flake path exists but is not a git checkout: $flake" >&2
  exit 1
fi

if [ ! -d "$flake/.git" ]; then
  mkdir -p "$(dirname "$flake")"
  git clone "$repo_url" "$flake"
else
  echo "Reusing existing flake checkout: $flake"
  git -C "$flake" pull --ff-only || true
fi

# Bootstrap the workspace: creates $workspace + .envrc + nix-uv env + folders.
RSM_WORKSPACE="$workspace" nix develop "$flake" -c rsm-setup
direnv allow "$workspace" || true
RSM_WORKSPACE="$workspace" nix develop "$flake" -c bash "$flake/tests/check-default.sh"
RSM_WORKSPACE="$workspace" nix develop "$flake" -c bash "$flake/tests/check-folders.sh"
'@

    Invoke-WslBash -User $script:EffectiveWslUser -Script $workspaceScript -Arguments @($RepoUrl, $WorkspacePath) -Description "RSM workspace setup"
    Write-BlankLine
}

function ConvertTo-WslPath {
    param([string]$WindowsPath)
    # C:\Users\me\x -> /mnt/c/Users/me/x  (drive letter lowercased, \ -> /)
    $p = $WindowsPath -replace '\\', '/'
    if ($p -match '^([A-Za-z]):/(.*)$') {
        return "/mnt/$($Matches[1].ToLowerInvariant())/$($Matches[2])"
    }
    return $p
}

function Install-WslRemoteExtensions {
    # VS Code splits extensions into a local (Windows/UI) side and a remote
    # (WSL) side. Install-VSCodeAndExtensions covers the UI side; coursework runs
    # in WSL, so Python/Jupyter/Quarto/etc. must also be installed into the WSL
    # remote. Do that automatically here (previously a manual `rsm-vscode-ext`
    # step) by running that same script inside WSL against the Windows VS Code
    # Linux CLI shim -- invoked from within WSL, `code --install-extension`
    # installs into ~/.vscode-server, i.e. the WSL remote.
    if ($SkipVSCode -or $SkipWorkspaceSetup) {
        Write-Detail "Skipping WSL VS Code extension install."
        return
    }

    Write-Section "Step 6: Installing VS Code extensions into the WSL remote..."

    $codeCommand = Find-VSCodeCommand
    if (-not $codeCommand) {
        Write-Detail "VS Code 'code' command not found; skipping remote extension install."
        Write-BlankLine
        return
    }
    # The Linux CLI shim sits next to code.cmd/code.exe as 'code' (no extension).
    $wslShim = ConvertTo-WslPath (Join-Path (Split-Path -Parent $codeCommand) "code")

    if ($DryRun) {
        Write-Detail "[dry-run] Would install WSL-remote extensions via: $wslShim --install-extension <id>"
        Write-BlankLine
        return
    }

    $extScript = @'
set -uo pipefail
code_shim="$1"
flake="$HOME/rsm-nix"
export RSM_FLAKE="$flake"
export RSM_CODE_BIN="$code_shim"
# Non-fatal: a missing/marketplace-less extension must never fail the install.
bash "$flake/bin/rsm-vscode-ext" || true
'@

    try {
        Invoke-WslBash -User $script:EffectiveWslUser -Script $extScript -Arguments @($wslShim) -Description "WSL remote VS Code extensions"
    } catch {
        Write-Detail "Remote extension install had problems (non-fatal): $($_.Exception.Message)"
    }
    Write-BlankLine
}

$script:EffectiveWslUser = Get-SafeWslUser -Candidate $WslUser

Write-Host "Rady School of Management @ UCSD" -ForegroundColor Cyan
Write-Host "RSM-MSBA Nix Installer for Windows + WSL2" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-BlankLine
Write-Detail "Distro: $DistroName"
Write-Detail "WSL user: $script:EffectiveWslUser"
Write-Detail "Workspace: $WorkspacePath"
if ($DryRun) {
    Write-Detail "Mode: dry-run (no host mutations)"
}
Write-BlankLine

Install-VSCodeAndExtensions
Install-NerdFont
Install-Tailscale
Ensure-WslFeature
Install-UbuntuDistro
Initialize-WslDistro
Configure-UbuntuUser
Install-RsmWorkspace
Install-WslRemoteExtensions

Write-Host "Installation complete." -ForegroundColor Green
Write-Host "Open VS Code, choose 'Connect to WSL', then open $WorkspacePath in $DistroName."

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
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$VSCodeExtensions = @(
    "ms-vscode-remote.remote-wsl",
    "ms-python.python",
    "ms-toolsai.jupyter",
    "quarto.quarto",
    "pinage404.nix-extension-pack"
)

$UbuntuDistributionInfoUrl = "https://raw.githubusercontent.com/microsoft/WSL/master/distributions/DistributionInfo.json"

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

function Test-WslOnlineDistroAvailable {
    param([string]$Name)

    $online = & wsl.exe --list --online 2>$null | Out-String
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
        foreach ($extension in $VSCodeExtensions) {
            Write-Detail "[dry-run] Would install VS Code extension $extension"
        }
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

    foreach ($extension in $VSCodeExtensions) {
        Write-Detail "Installing VS Code extension $extension..."
        & $codeCommand --install-extension $extension --force | Out-Host
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to install VS Code extension $extension."
        }
    }

    Write-BlankLine
}

function Ensure-WslFeature {
    Write-Section "Step 2: Checking WSL2..."

    if (-not (Get-CommandPathOrNull "wsl.exe")) {
        throw "wsl.exe was not found. This installer requires Windows 11 or Windows 10 21H2+."
    }

    if ($DryRun) {
        Write-Detail "[dry-run] Verifying WSL command availability..."
        & wsl.exe --status | Out-Host
        Write-Detail "[dry-run] Would run: wsl --update --web-download"
        Write-Detail "[dry-run] Would run: wsl --set-default-version 2"
        Write-BlankLine
        return
    }

    $status = & wsl.exe --status 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        if (-not (Test-IsAdministrator)) {
            throw "WSL is not ready. Rerun this PowerShell script as Administrator so it can enable WSL, then reboot if Windows asks."
        }
        Write-Detail "Installing WSL without a default distro..."
        & wsl.exe --install --no-distribution
        if ($LASTEXITCODE -ne 0) {
            throw "WSL installation failed. Reboot if Windows requested it, then rerun this installer."
        }
    } else {
        Write-Detail ($status.Trim() -replace "`r?`n", "; ")
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

    if (-not (Test-Path $imagePath)) {
        Write-Detail "Downloading Ubuntu WSL image for $($ImageInfo.Architecture)..."
        Invoke-WebRequest -Uri $ImageInfo.Url -OutFile $imagePath
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
            Invoke-CheckedCommand "wsl.exe" @("--set-version", $DistroName, "2") "Could not ensure $DistroName uses WSL2."
            Write-BlankLine
            return
        }
    }

    if (Test-WslOnlineDistroAvailable -Name $DistroName) {
        Write-Detail "Installing $DistroName from WSL online distro list..."
        & wsl.exe --install -d $DistroName --web-download --no-launch
        if ($LASTEXITCODE -ne 0) {
            throw "Installing $DistroName failed. Reboot if Windows requested it, then rerun this installer."
        }
    } else {
        $image = Get-UbuntuWslImageInfo -Name $DistroName
        $imagePath = Download-UbuntuWslImage -ImageInfo $image
        $help = & wsl.exe --help | Out-String
        if ($help -notmatch "--from-file") {
            throw "$DistroName is not listed by WSL, and this WSL version does not support installing .wsl files. Run 'wsl --update --web-download', reboot, and rerun."
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

    Invoke-CheckedCommand "wsl.exe" @("--set-version", $DistroName, "2") "Could not ensure $DistroName uses WSL2."
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

    $normalized = $Script -replace "`r`n", "`n"
    $command = @("-d", $DistroName, "--user", $User, "--", "bash", "-se", "--") + $Arguments
    $normalized | & wsl.exe @command
    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed."
    }
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
  xz-utils

if ! id -u "$wsl_user" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "$wsl_user"
fi

usermod -aG sudo "$wsl_user"
printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$wsl_user" >"/etc/sudoers.d/90-rsm-nix-$wsl_user"
chmod 0440 "/etc/sudoers.d/90-rsm-nix-$wsl_user"

cat >/etc/wsl.conf <<EOF
[user]
default=$wsl_user

[boot]
systemd=true
EOF
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

case "$workspace" in
  "~") workspace="$HOME" ;;
  "~/"*) workspace="$HOME/${workspace#~/}" ;;
esac

if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

if ! command -v nix >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
fi

if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "Nix was installed, but the nix command is not active in this shell." >&2
  exit 1
fi

if ! command -v direnv >/dev/null 2>&1; then
  nix profile install nixpkgs#direnv
fi

if [ ! -e "$HOME/.nix-profile/share/nix-direnv/direnvrc" ]; then
  nix profile install nixpkgs#nix-direnv
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

if [ -e "$workspace" ] && [ ! -d "$workspace/.git" ]; then
  echo "Workspace path exists but is not a git checkout: $workspace" >&2
  exit 1
fi

if [ ! -d "$workspace/.git" ]; then
  mkdir -p "$(dirname "$workspace")"
  git clone "$repo_url" "$workspace"
else
  echo "Reusing existing workspace: $workspace"
fi

cd "$workspace"
direnv allow || true
nix develop -c bash tests/check-no-host-mutation.sh
nix develop -c rsm-setup
nix develop -c bash tests/check-default.sh
nix develop -c bash tests/check-folders.sh
nix develop -c bash tests/check-no-host-mutation.sh
'@

    Invoke-WslBash -User $script:EffectiveWslUser -Script $workspaceScript -Arguments @($RepoUrl, $WorkspacePath) -Description "RSM workspace setup"
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
Ensure-WslFeature
Install-UbuntuDistro
Configure-UbuntuUser
Install-RsmWorkspace

Write-Host "Installation complete." -ForegroundColor Green
Write-Host "Open VS Code, choose 'Connect to WSL', then open $WorkspacePath in $DistroName."

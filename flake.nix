{
  description = "RSM-MSBA host-native computing environment (Nix flake)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system:
          f (import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          }));

      # --- Quarto pinned to a single version across all platforms ----------
      # Keeping every student on the same Quarto build is the whole point, so
      # we fetch the official release rather than tracking nixpkgs' version.
      quartoVersion = "1.9.13";
      quartoSources = {
        aarch64-linux = {
          kind = "deb";
          file = "quarto-${quartoVersion}-linux-arm64.deb";
          hash = "sha256-cLZN/KWynNPy94ujLRSnmfox2Yey1WTvO69+dTywn/U=";
        };
        x86_64-linux = {
          kind = "deb";
          file = "quarto-${quartoVersion}-linux-amd64.deb";
          hash = "sha256-NsKQGDqnDP0IaBrLh4cXKU6gPg67Skk/LsPLQoSxa88=";
        };
        aarch64-darwin = {
          kind = "tgz";
          file = "quarto-${quartoVersion}-macos.tar.gz";
          hash = "sha256-549b0qqJ11eqohurEIjV5frYb4Ibev4IWCfscqc30Pk=";
        };
        x86_64-darwin = {
          kind = "tgz";
          file = "quarto-${quartoVersion}-macos.tar.gz";
          hash = "sha256-549b0qqJ11eqohurEIjV5frYb4Ibev4IWCfscqc30Pk=";
        };
      };

      mkQuarto = pkgs:
        let
          system = pkgs.stdenv.hostPlatform.system;
          src = quartoSources.${system};
          url = "https://github.com/quarto-dev/quarto-cli/releases/download/v${quartoVersion}/${src.file}";
          fetched = pkgs.fetchurl { inherit url; hash = src.hash; };
        in
        if src.kind == "deb" then
          pkgs.stdenvNoCC.mkDerivation {
            pname = "quarto-bin";
            version = quartoVersion;
            src = fetched;
            nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.dpkg ];
            buildInputs = [
              pkgs.curl
              pkgs.openssl
              pkgs.stdenv.cc.cc.lib
              pkgs.zlib
            ];
            unpackPhase = ''dpkg-deb -x "$src" .'';
            installPhase = ''
              runHook preInstall
              mkdir -p "$out/opt" "$out/bin"
              cp -a opt/quarto "$out/opt/quarto"
              ln -s "$out/opt/quarto/bin/quarto" "$out/bin/quarto"
              runHook postInstall
            '';
          }
        else
          # macOS: the release tarball ships native Mach-O binaries (incl. a
          # bundled deno), so no patching is required.
          pkgs.stdenvNoCC.mkDerivation {
            pname = "quarto-bin";
            version = quartoVersion;
            src = fetched;
            sourceRoot = ".";
            installPhase = ''
              runHook preInstall
              mkdir -p "$out/opt" "$out/bin"
              qbin="$(find . -type f -path '*/bin/quarto' -print -quit)"
              if [ -z "$qbin" ]; then
                echo "could not locate bin/quarto in the Quarto tarball" >&2
                exit 1
              fi
              qroot="$(dirname "$(dirname "$qbin")")"
              cp -a "$qroot" "$out/opt/quarto"
              chmod +x "$out/opt/quarto/bin/quarto"
              ln -s "$out/opt/quarto/bin/quarto" "$out/bin/quarto"
              runHook postInstall
            '';
          };

      # --- rsm-* helper commands ------------------------------------------
      # Each command is the shared env header (bin/rsm-env.sh) prepended to the
      # specific script body, wrapped so its runtime tools are always on PATH.
      rsmEnvHeader = builtins.readFile ./bin/rsm-env.sh;

      # Native runtime + build environment for the uv-installed Python wheels.
      # Applied wherever rsm-* commands run — the dev shell, direnv, or `nix run`
      # — so behaviour is identical on a laptop, in WSL, and on the server.
      #
      #  * Linux runtime: the uv env uses the Nix CPython, whose loader does not
      #    search system lib dirs, so manylinux wheels (numpy, xgboost, ...) need
      #    libstdc++/libgomp/zlib on LD_LIBRARY_PATH on EVERY Linux, not just NixOS.
      #  * Linux build: some deps ship no aarch64 wheel (scikit-misc, pulled in by
      #    pyrsm) and are compiled from source on Windows-ARM/WSL + ARM Linux.
      #    Point pkg-config at the Nix CPython so meson uses its Python headers
      #    instead of a stray system python (an incomplete /usr python3.14-dev
      #    otherwise hijacks the build and fails it).
      #  * macOS runtime: the xgboost wheel links @rpath/libomp.dylib but only
      #    searches Homebrew paths; expose the Nix OpenMP runtime as a fallback so
      #    xgboost imports without `brew install libomp`.
      nativeEnvHook = pkgs:
        pkgs.lib.optionalString pkgs.stdenv.isLinux ''
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib pkgs.zlib ]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
          export PKG_CONFIG_PATH="${pkgs.python313}/lib/pkgconfig''${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
        '' + pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
          # RSM_OMP_LIBDIR is a SIP-SAFE twin of the OpenMP path below. macOS SIP
          # strips every DYLD_* var from the environment a protected shell (the
          # default /bin/zsh) hands to its children, so DYLD_FALLBACK_LIBRARY_PATH
          # is gone before python starts in a TERMINAL -- xgboost then can't find
          # libomp there even though it works in a kernel. A var not named DYLD_*
          # survives that hop, so the sitecustomize preload (shell/rsm-sitecustomize.py,
          # installed on PYTHONPATH by rsm-setup) reads this to load libomp by path.
          export RSM_OMP_LIBDIR="${pkgs.lib.makeLibraryPath [ pkgs.llvmPackages.openmp ]}"
          export DYLD_FALLBACK_LIBRARY_PATH="$RSM_OMP_LIBDIR''${DYLD_FALLBACK_LIBRARY_PATH:+:$DYLD_FALLBACK_LIBRARY_PATH}"
        '';

      mkRsmScripts = pkgs:
        let
          mk = name: runtimeInputs: pkgs.writeShellApplication {
            inherit name runtimeInputs;
            excludeShellChecks = [ "SC1090" "SC1091" "SC2164" ];
            text = rsmEnvHeader + "\n" + nativeEnvHook pkgs + builtins.readFile (./bin + "/${name}");
          };
          # On Linux, deps without an aarch64 wheel (scikit-misc) are compiled
          # from source, so rsm-python-sync needs a C/Fortran toolchain +
          # pkg-config on PATH. gfortran's wrapper bundles cc/gcc/g++ too.
          pythonSync = mk "rsm-python-sync"
            ([ pkgs.uv pkgs.python313 pkgs.coreutils ]
              ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.gfortran pkgs.pkg-config ]);
          pgInit = mk "rsm-pg-init" [ pkgs.postgresql_16 pkgs.coreutils ];

          # Assembled oh-my-zsh + powerlevel10k + plugins for the rsm-msba ZDOTDIR
          # (installed into the workspace by rsm-setup). Built from nixpkgs, so
          # there is no per-user cloning from GitHub.
          zshOmz = pkgs.runCommand "rsm-zsh-omz" { } ''
            mkdir -p "$out"
            cp -r ${pkgs.oh-my-zsh}/share/oh-my-zsh "$out/.oh-my-zsh"
            chmod -R u+w "$out/.oh-my-zsh"
            mkdir -p "$out/.oh-my-zsh/custom/themes" "$out/plugins"
            ln -s ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k "$out/.oh-my-zsh/custom/themes/powerlevel10k"
            ln -s ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions "$out/plugins/zsh-autosuggestions"
            ln -s ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting "$out/plugins/zsh-syntax-highlighting"
          '';

          # macOS: a copy of the Nix OpenMP runtime whose install name is rewritten
          # to `@rpath/libomp.dylib` (+ ad-hoc re-signed). The xgboost/lightgbm
          # wheels dlopen `@rpath/libomp.dylib`; once THIS copy is preloaded (by
          # the sitecustomize on PYTHONPATH) it is resident under exactly that name,
          # so their dlopen reuses it -- no Homebrew libomp, no DYLD_* (which macOS
          # SIP strips in a terminal). The stock Nix libomp cannot do this: its
          # install name is its absolute /nix/store path, which never matches an
          # `@rpath/libomp.dylib` request. Built here so students need no Xcode CLT.
          ompRpath =
            if pkgs.stdenv.isDarwin then
              pkgs.runCommand "rsm-libomp-rpath"
                { nativeBuildInputs = [ pkgs.darwin.cctools pkgs.darwin.sigtool ]; }
                ''
                  mkdir -p "$out/lib"
                  cp ${pkgs.llvmPackages.openmp}/lib/libomp.dylib "$out/lib/libomp.dylib"
                  chmod u+w "$out/lib/libomp.dylib"
                  install_name_tool -id @rpath/libomp.dylib "$out/lib/libomp.dylib"
                  codesign -f -s - "$out/lib/libomp.dylib"
                ''
            else null;
        in
        rec {
          rsm-python-sync = pythonSync;
          rsm-pg-init = pgInit;
          # rsm-setup is built directly (not via mk) so it can carry the paths to
          # the assembled zsh assets + the ZDOTDIR template it installs.
          rsm-setup = pkgs.writeShellApplication {
            name = "rsm-setup";
            runtimeInputs = [ pythonSync pkgs.uv pkgs.python313 pkgs.coreutils pkgs.git pkgs.nodejs_22 rsm-version rsm-vscode-settings rsm-vscode-ext rsm-vscode-keybindings rsm-claude-settings rsm-mkdir ];
            excludeShellChecks = [ "SC1090" "SC1091" "SC2164" ];
            text = rsmEnvHeader + "\n" + nativeEnvHook pkgs + ''
              export RSM_OMZ_SRC="${zshOmz}"
              export RSM_ZDOTDIR_TEMPLATE="${./shell/zdotdir}"
              export RSM_SKILLS_SRC="${./skills}"
              export RSM_SITECUSTOMIZE_SRC="${./shell/rsm-sitecustomize.py}"
            '' + pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
              export RSM_OMP_RPATH_LIB="${ompRpath}/lib/libomp.dylib"
            '' + builtins.readFile ./bin/rsm-setup;
          };
          # Bootstrap/reset: clone the flake if missing, then rsm-setup. Lives on
          # the server PATH so `rm -rf ~/rsm-msba ~/rsm-nix && rsm-msba` recovers.
          rsm-msba = mk "rsm-msba" [ rsm-setup pkgs.coreutils ];
          # `rsm-update` is a friendlier name for the same idempotent operation
          # (pull the flake, re-sync, refresh shell/examples, update Claude Code
          # to the latest). It sets RSM_CLAUDE_LATEST so Claude is bumped.
          rsm-update = mk "rsm-update" [ rsm-setup pkgs.coreutils ];
          # rsm-mkdir: the "make a first-class RSM folder anywhere" command
          # (CWD-relative like mkdir; nested via source_up or standalone via
          # `use flake`; multi-path; --venv for an own reproducible venv). Does
          # the per-folder work directly (writes .envrc + .vscode + direnv allow);
          # rsm-clone and rsm-setup call it too.
          rsm-mkdir = mk "rsm-mkdir" [ rsm-vscode-settings rsm-claude-settings pkgs.uv pkgs.direnv pkgs.coreutils ];
          # rsm-clone: git clone + make the clone direnv-ready (rsm-mkdir) in one step.
          rsm-clone = mk "rsm-clone" [ pkgs.git rsm-mkdir pkgs.coreutils ];
          # Prints the rsm-nix version (the flake's git commit) + platform/python,
          # so it is easy to confirm everyone is on the same environment.
          rsm-version = mk "rsm-version" [ pkgs.git pkgs.coreutils pkgs.gawk ];
          rsm-pg-start = mk "rsm-pg-start" [ pgInit pkgs.postgresql_16 pkgs.coreutils pkgs.gnugrep ];
          rsm-pg-stop = mk "rsm-pg-stop" [ pkgs.postgresql_16 pkgs.coreutils ];
          rsm-pg-status = mk "rsm-pg-status" [ pkgs.postgresql_16 pkgs.coreutils ];
          rsm-pg-psql = mk "rsm-pg-psql" [ pkgs.postgresql_16 ];
          rsm-pgweb = mk "rsm-pgweb" [ pkgs.pgweb ];
          pg = mk "pg" [ rsm-pg-start rsm-pg-stop rsm-pg-status rsm-pg-psql rsm-pgweb rsm-pg-init pkgs.postgresql_16 pkgs.coreutils ];
          # Ensures ~/.ssh/id_ed25519 exists and adds the RSM server to
          # ~/.ssh/config (idempotent). Run by the installers (key) and by
          # `rsm-github` (key + server config); mirrors both to Windows on WSL.
          rsm-ssh-setup = mk "rsm-ssh-setup" [ pkgs.openssh pkgs.git pkgs.gawk pkgs.coreutils ];
          # One-time Git identity + GitHub SSH key setup. Named rsm-github (not
          # `github`) so a browser-opening `github` alias -- oh-my-zsh's
          # web-search plugin, GitHub Desktop -- cannot shadow it (aliases beat
          # PATH). `github` is kept as a thin back-compat wrapper that execs this.
          rsm-github = mk "rsm-github" [ pkgs.git pkgs.openssh pkgs.curl rsm-ssh-setup ];
          github = mk "github" [ rsm-github ];
          # Installs the curated VS Code extensions (vscode/extensions.txt) into
          # the remote `code` is connected to — run from the VS Code WSL/SSH
          # integrated terminal so they land in the remote, not just the laptop.
          rsm-vscode-ext = mk "rsm-vscode-ext" [ pkgs.coreutils ];
          # Writes a folder's .vscode/{settings,extensions,keybindings}.json
          # (interpreter, RSM terminal shell, curated settings). Shared by
          # rsm-setup + rsm-mkdir.
          rsm-vscode-settings = mk "rsm-vscode-settings" [ pkgs.coreutils pkgs.gnused pkgs.gnugrep ];
          # Writes the per-folder Claude Code "agentic engineering" harness
          # (.claude/ {settings,hooks,commands,usage-log} + CLAUDE.md + justfile).
          # Shared by rsm-setup (workspace root) + rsm-mkdir (nested folders);
          # reads curated source from the live flake path $RSM_FLAKE/claude.
          rsm-claude-settings = mk "rsm-claude-settings" [ pkgs.coreutils pkgs.gnused pkgs.gnugrep ];
          # Merges the curated VS Code keybindings (vscode/keybindings.json) into
          # the User keybindings.json. User-scoped (VS Code has no per-workspace
          # keybindings); called by rsm-setup on a laptop only.
          rsm-vscode-keybindings = mk "rsm-vscode-keybindings" [ pkgs.coreutils ];
          # Verifies a project's env: imports each declared dependency and flags
          # anything that fails to load (missing package or missing system lib).
          rsm-project-check = mk "rsm-project-check" [ pkgs.coreutils ];
        };
    in
    {
      packages = forAllSystems (pkgs:
        let
          system = pkgs.stdenv.hostPlatform.system;
          rsmScripts = mkRsmScripts pkgs;
          quarto = mkQuarto pkgs;
          sparkHadoop = import ./spark-hadoop {
            inherit pkgs;
            python = pkgs.python313;
          };
        in
        rsmScripts // {
          quarto-bin = quarto;
          spark-hadoop-env = sparkHadoop.sparkHadoopEnv;
          spark-hadoop-proof = sparkHadoop.proof;
          default = rsmScripts.rsm-setup;
        });

      devShells = forAllSystems (pkgs:
        let
          rsmScripts = mkRsmScripts pkgs;
          quarto = mkQuarto pkgs;
          rsmScriptList = builtins.attrValues rsmScripts;

          corePackages = with pkgs; [
            python313
            uv
            quarto
            postgresql_16
            pgweb
            duckdb # the `duckdb` CLI (the Python `duckdb` package is separate, via uv)
            git
            git-lfs
            gh
            nodejs_22 # Node runtime for Claude Code (installed per-user via npm)
            prettier # markdown/JS/JSON formatter (also normalizes rendered docs)
            graphviz
            zsh
            eza # modern `ls` (ls/lsa/lt aliases in the rsm shell)
            zoxide # `z <name>` to jump to folders
            cacert
            coreutils
            gnused
            gnugrep
            which
            just # simple task runner for the per-folder justfile (test/check/review/save/verify)
            jq # JSON processor used by the Claude Code hooks (secret-scan, usage-log)
            ruff # Python linter/formatter used by the Claude Code hooks
          ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
            # C/Fortran toolchain for source-built wheels that ship no aarch64
            # wheel (scikit-misc). gfortran's wrapper provides cc/gcc/g++ too.
            pkgs.gfortran
            pkgs.pkg-config
          ] ++ rsmScriptList;

          baseHook = ''
            ${rsmEnvHeader}
            export SSL_CERT_FILE="''${SSL_CERT_FILE:-${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt}"
            export NIX_SSL_CERT_FILE="''${NIX_SSL_CERT_FILE:-$SSL_CERT_FILE}"
          '' + nativeEnvHook pkgs + ''
            ${builtins.readFile ./shell/rsm-shell-hook.sh}
          '';

          sparkHadoop = import ./spark-hadoop {
            inherit pkgs;
            # PySpark should drive the uv base env when it exists.
            python = pkgs.python313;
          };
        in
        {
          default = pkgs.mkShell {
            packages = corePackages;
            shellHook = baseHook;
          };

          spark-hadoop = pkgs.mkShell {
            packages = corePackages ++ [
              sparkHadoop.java
              sparkHadoop.sparkHadoopEnv
              sparkHadoop.proof
            ];
            shellHook = baseHook + ''
              # Prefer the uv base interpreter for PySpark if it is built.
              if [ -x "$RSM_UV_ENV/bin/python3" ]; then
                export PYSPARK_PYTHON="$RSM_UV_ENV/bin/python3"
                export PYSPARK_DRIVER_PYTHON="$RSM_UV_ENV/bin/python3"
              fi
              ${sparkHadoop.envHook}
              echo "[spark-hadoop] JAVA_HOME=$JAVA_HOME"
              echo "[spark-hadoop] SPARK_HOME=$SPARK_HOME"
              echo "[spark-hadoop] proof: run 'rsm-spark-hadoop-proof'"
            '';
          };
        });

      apps = forAllSystems (pkgs:
        let
          system = pkgs.stdenv.hostPlatform.system;
          rsmScripts = mkRsmScripts pkgs;
          sparkHadoop = import ./spark-hadoop {
            inherit pkgs;
            python = pkgs.python313;
          };
          checkApp = pkgs.writeShellApplication {
            name = "rsm-check";
            runtimeInputs = (builtins.attrValues rsmScripts) ++ (with pkgs; [
              python313
              uv
              (mkQuarto pkgs)
              postgresql_16
              pgweb
              git
              git-lfs
              gh
              nodejs_22
              coreutils
              gnugrep
            ]);
            excludeShellChecks = [ "SC1090" "SC1091" "SC2164" ];
            text = rsmEnvHeader + "\n" + nativeEnvHook pkgs + builtins.readFile ./tests/check-default.sh;
          };
        in
        {
          check = {
            type = "app";
            program = "${checkApp}/bin/rsm-check";
            meta.description = "Run the RSM-MSBA default-shell smoke checks";
          };
          check-spark-hadoop = {
            type = "app";
            program = "${sparkHadoop.proof}/bin/rsm-spark-hadoop-proof";
            meta.description = "Run the RSM-MSBA Spark/Hadoop PySpark proof";
          };
          rsm-setup = {
            type = "app";
            program = "${rsmScripts.rsm-setup}/bin/rsm-setup";
            meta.description = "Bootstrap the RSM-MSBA workspace (uv env, kernel, folders)";
          };
        });

      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);
    };
}

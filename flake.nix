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

      # On Linux the uv base env uses the Nix Python interpreter, whose loader
      # does not search system lib dirs. manylinux wheels (numpy, xgboost, ...)
      # therefore need libstdc++/libgomp/zlib on LD_LIBRARY_PATH on EVERY Linux
      # (Ubuntu included), not just NixOS. Baked into the env header so it
      # applies whether a command runs in the dev shell, via direnv, or `nix run`.
      ldLibHook = pkgs: pkgs.lib.optionalString pkgs.stdenv.isLinux ''
        export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib pkgs.zlib ]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      '';

      mkRsmScripts = pkgs:
        let
          mk = name: runtimeInputs: pkgs.writeShellApplication {
            inherit name runtimeInputs;
            excludeShellChecks = [ "SC1090" "SC1091" "SC2164" ];
            text = rsmEnvHeader + "\n" + ldLibHook pkgs + builtins.readFile (./bin + "/${name}");
          };
          pythonSync = mk "rsm-python-sync" [ pkgs.uv pkgs.python313 pkgs.coreutils ];
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
        in
        rec {
          rsm-python-sync = pythonSync;
          rsm-pg-init = pgInit;
          # rsm-setup is built directly (not via mk) so it can carry the paths to
          # the assembled zsh assets + the ZDOTDIR template it installs.
          rsm-setup = pkgs.writeShellApplication {
            name = "rsm-setup";
            runtimeInputs = [ pythonSync pkgs.uv pkgs.python313 pkgs.coreutils pkgs.git ];
            excludeShellChecks = [ "SC1090" "SC1091" "SC2164" ];
            text = rsmEnvHeader + "\n" + ldLibHook pkgs + ''
              export RSM_OMZ_SRC="${zshOmz}"
              export RSM_ZDOTDIR_TEMPLATE="${./shell/zdotdir}"
            '' + builtins.readFile ./bin/rsm-setup;
          };
          # Bootstrap/reset: clone the flake if missing, then rsm-setup. Lives on
          # the server PATH so `rm -rf ~/rsm-msba ~/rsm-nix && rsm-msba` recovers.
          rsm-msba = mk "rsm-msba" [ rsm-setup pkgs.coreutils ];
          rsm-new-course = mk "rsm-new-course" [ pkgs.coreutils pkgs.gnugrep ];
          rsm-pg-start = mk "rsm-pg-start" [ pgInit pkgs.postgresql_16 pkgs.coreutils pkgs.gnugrep ];
          rsm-pg-stop = mk "rsm-pg-stop" [ pkgs.postgresql_16 pkgs.coreutils ];
          rsm-pg-status = mk "rsm-pg-status" [ pkgs.postgresql_16 pkgs.coreutils ];
          rsm-pg-psql = mk "rsm-pg-psql" [ pkgs.postgresql_16 ];
          rsm-pgweb = mk "rsm-pgweb" [ pkgs.pgweb ];
          pg = mk "pg" [ rsm-pg-start rsm-pg-stop rsm-pg-status rsm-pg-psql rsm-pgweb rsm-pg-init pkgs.postgresql_16 pkgs.coreutils ];
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
            git
            git-lfs
            gh
            graphviz
            zsh
            cacert
            coreutils
            gnused
            gnugrep
            which
          ] ++ rsmScriptList;

          baseHook = ''
            ${rsmEnvHeader}
            export SSL_CERT_FILE="''${SSL_CERT_FILE:-${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt}"
            export NIX_SSL_CERT_FILE="''${NIX_SSL_CERT_FILE:-$SSL_CERT_FILE}"
          '' + ldLibHook pkgs + ''
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
              coreutils
              gnugrep
            ]);
            excludeShellChecks = [ "SC1090" "SC1091" "SC2164" ];
            text = rsmEnvHeader + "\n" + ldLibHook pkgs + builtins.readFile ./tests/check-default.sh;
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

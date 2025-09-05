{
  inputs = {
    nixpkgs.url = "nixpkgs/25.05";
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      git-hooks,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        checkFlakes = pkgs.writeShellApplication {
          name = "check-flakes";
          text = ''
            find . -name flake.nix -exec dirname {} \; | while read -r flake; do
              echo "=== Checking flake $flake ==="
              nix flake check --all-systems --print-build-logs --keep-going --impure "$flake"
            done
          '';
        };

        updateFlakes = pkgs.writeShellApplication {
          name = "update-flakes";
          text = ''
            find . -name flake.nix -exec dirname {} \; | while read -r flake; do
              echo "=== Updating flake $flake ==="
              nix flake update --flake "$flake"
            done
          '';
        };

        createSlides = pkgs.writeShellApplication {
          name = "slides";
          runtimeInputs = [
            pkgs.marp-cli
          ];
          text = ''
            set -e
            INPUT="workshop.md"
            OUTPUT_DIR="''${1:-slides}"
            mkdir -p "$OUTPUT_DIR"
            marp --html \
                 --output "$OUTPUT_DIR/index.html" \
                 "$INPUT"
            echo "Slides generated at $OUTPUT_DIR/index.html"
          '';
        };
      in
      {
        checks = {
          pre-commit-check = git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              black.enable = true;

              cspell = {
                enable = true;
                args = [
                  "--no-must-find-files"
                ];
              };

              nixfmt-rfc-style.enable = true;

              markdownlint = {
                enable = true;
                entry = "${pkgs.nodePackages.markdownlint-cli2}/bin/markdownlint-cli2";
                files = "\\.md$";
              };

              prettier.enable = true;
            };
          };
        };

        formatter =
          let
            config = self.checks.${system}.pre-commit-check.config;
            inherit (config) package configFile;
            script = ''
              ${package}/bin/pre-commit run --all-files --config ${configFile}
            '';
          in
          pkgs.writeShellScriptBin "pre-commit-run" script;

        packages = {
          slides = pkgs.stdenv.mkDerivation {
            pname = "slides";
            version = "0.1.0";
            src = ./.;
            nativeBuildInputs = [
              createSlides
            ];
            buildPhase = ''
              slides "$out"
            '';
            installPhase = "true";
          };
        };

        apps = {
          checkFlakes = {
            type = "app";
            program = "${checkFlakes}/bin/check-flakes";
          };

          updateFlakes = {
            type = "app";
            program = "${updateFlakes}/bin/update-flakes";
          };

          slides = {
            type = "app";
            program = "${createSlides}/bin/slides";
          };
        };

        devShells.default = pkgs.mkShell {
          name = "nix-mini-workshop";

          inputsFrom = [
            self.checks.${system}.pre-commit-check
          ];

          packages = [
            pkgs.marp-cli
          ];

          shellHook = ''
            echo "Development shell for improving the Nix mini-workshop"
          '';
        };
      }
    );
}

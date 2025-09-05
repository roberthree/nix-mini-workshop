{
  description = "Matplotlib example";
  inputs = {
    nixpkgs.url = "nixpkgs/25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pythonEnvironment = (
          pkgs.python3.withPackages (packages: [
            packages.matplotlib
            packages.numpy
          ])
        );
      in
      {
        devShells.default = pkgs.mkShell {
          name = "python-with-matplotlib";
          packages = [
            pythonEnvironment
            pkgs.black
          ];
        };

        packages = {
          interference = pkgs.python3Packages.buildPythonPackage {
            pname = "interference";
            version = "0.1.0";
            src = ./.;
            pyproject = true;
            nativeBuildInputs = with pkgs.python3Packages; [
              setuptools
              wheel
            ];
            propagatedBuildInputs = with pkgs.python3Packages; [
              numpy
              matplotlib
            ];
          };

          create-interference = pkgs.python3Packages.buildPythonApplication {
            pname = "create-interference";
            version = "0.1.0";
            src = ./.;
            pyproject = true;
            nativeBuildInputs = with pkgs.python3Packages; [
              setuptools
              wheel
            ];
            propagatedBuildInputs = with pkgs.python3Packages; [
              numpy
              matplotlib
            ];
          };
        };

        apps = {
          create-interference = {
            type = "app";
            program = "${self.packages.${system}.create-interference}/bin/interference-pattern";
          };
        };
      }
    );
}

{
  inputs = {
    nixpkgs.url = "nixpkgs/25.05";
    flake-utils.url = "github:numtide/flake-utils";
    # We are now "chaining" our existing package flake to this devShell flake
    myPackages.url = "path:../packages";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      myPackages,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells =
          let
            pkgs = nixpkgs.legacyPackages.${system};
            myPackagesReused = myPackages.packages.${system};
            pythonEnvironment = pkgs.python3.withPackages (
              python_packages: with python_packages; [
                black
              ]
            );
          in
          {
            pythonWithFun = pkgs.mkShell {
              name = "python-with-fun";
              packages = [
                myPackagesReused.bastet
                myPackagesReused.t2048
                pythonEnvironment
              ];
              shellHook = ''
                echo "👋 Hello $USER! Welcome to your Python playground!"
                echo "Type 'python' to start coding and use 'black your_script.py' to format your code."
                echo "If you are bored, you can also play 'bastet' or '2048-in-terminal' for fun!"
              '';
            };
          };
      }
    );
}

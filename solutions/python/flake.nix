{
  inputs = {
    nixpkgs.url = "nixpkgs/25.05";
    flake-utils.url = "github:numtide/flake-utils";
    solutionMatplotlib.url = "path:../matplotlib";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      solutionMatplotlib,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          name = "python";
          packages = [
            (pkgs.python3.withPackages (packages: [
              packages.numpy
            ]))
            solutionMatplotlib.packages.${system}.interference
            pkgs.black
          ];
        };
      }
    );
}

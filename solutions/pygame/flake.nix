{
  description = "Pygame example";
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
            packages.pygame
          ])
        );
      in
      {
        devShells.default = pkgs.mkShell {
          name = "python-with-pygame";
          packages = [
            pythonEnvironment
            pkgs.black
          ];
        };

        packages = {
          move-ball = pkgs.writeShellApplication {
            name = "move-ball";
            text = ''exec ${pythonEnvironment}/bin/python ${./game.py} "$@"'';
          };
        };

        apps = {
          move-ball = {
            type = "app";
            program = "${self.packages.${system}.move-ball}/bin/move-ball";
          };
        };
      }
    );
}

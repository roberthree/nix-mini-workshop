{
  description = "Video processing with OpenCV";
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
            packages.opencv4
            packages.tqdm
          ])
        );
      in
      {
        devShells.default = pkgs.mkShell {
          name = "python-with-opencv";
          packages = [
            pythonEnvironment
            pkgs.black
          ];
        };

        packages = {
          cartoonize = pkgs.writeShellApplication {
            name = "cartoonize";
            text = ''exec ${pythonEnvironment}/bin/python ${./video_filter.py} "$@"'';
          };
        };

        apps = {
          cartoonize = {
            type = "app";
            program = "${self.packages.${system}.cartoonize}/bin/cartoonize";
          };
        };
      }
    );
}

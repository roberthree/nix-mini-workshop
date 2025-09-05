{
  description = "ASCII art from images using python-ascii_magic";

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
            packages.ascii-magic
            # packages.pillow
            # packages.colorama
          ])
        );
      in
      {
        devShells.default = pkgs.mkShell {
          name = "python-with-ascii";
          packages = [
            pythonEnvironment
            pkgs.black
          ];
        };

        packages = {
          ascii-art = pkgs.writeScriptBin "ascii-art" ''
            #!${pythonEnvironment}/bin/python
            import argparse
            from ascii_magic import AsciiArt

            parser = argparse.ArgumentParser(description="Render an image as ASCII art")
            parser.add_argument("image", help="Path to an image file (png/jpg)")
            parser.add_argument("--columns", type=int, default=120, help="Characters per row (default: 120)")
            parser.add_argument("--monochrome", action="store_true", help="Disable color in terminal")
            args = parser.parse_args()

            art = AsciiArt.from_image(args.image)
            art.to_terminal(columns=args.columns, monochrome=args.monochrome)
          '';
        };

        apps = {
          ascii-art = {
            type = "app";
            program = "${self.packages.${system}.ascii-art}/bin/ascii-art";
            meta.description = "Convert an image to terminal/HTML ASCII art";
          };
        };
      }
    );
}

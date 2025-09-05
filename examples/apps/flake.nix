{
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
      in
      {
        packages =
          let
            pythonEnvironment = pkgs.python3.withPackages (
              # [`with ...; ...`](https://nix.dev/tutorials/nix-language.html#with)
              python_packages: with python_packages; [
                pandas
                pyarrow
              ]
            );
            csv2arrow = pkgs.writeScriptBin "csv2arrow" ''
              #!${pythonEnvironment}/bin/python
              import sys, pandas as pd
              if len(sys.argv) != 3:
                  print("Usage: csv2arrow input.csv output.arrow")
                  sys.exit(1)
              input, output = sys.argv[1], sys.argv[2]
              df = pd.read_csv(input)
              df.to_feather(output)
              print(f"Wrote '{input}' to '{output}':\n{df}")
            '';
          in
          {
            csv2arrow = csv2arrow;
          };

        apps = {
          csv2arrow = {
            type = "app";
            program = "${self.packages.${system}.csv2arrow}/bin/csv2arrow";
          };
        };
      }
    );
}

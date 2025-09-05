# We define here a nix expression containing the flake
{
  # We define here our flake inputs, e.g. an existing package collection
  inputs = {
    # nixpkgs is a big package collection, here pinned to branch nixos-25.05
    nixpkgs.url = "nixpkgs/25.05";
    # pure Nix flake utility functions
    flake-utils.url = "github:numtide/flake-utils";
  };

  # We define here our flake outputs, e.g. simple packages
  outputs =
    # The `:` indicates a [function](https://nix.dev/tutorials/nix-language.html#functions)
    # - on its left the arguments
    # - on its right the body
    #
    # `self` refers to the current flake and `nixpkgs` and `flake-utils` to the inputs defined earlier
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    # utility function applying the argument to each default system
    flake-utils.lib.eachDefaultSystem (
      system:
      # [`let ... in ...`](https://nix.dev/tutorials/nix-language.html#let-in) allows us to define variables in the `let`-block to be used in the `in`-expression
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Define the packages
        packages = {
          bastet = pkgs.bastet;
          t2048 = pkgs._2048-in-terminal;
        };
      }
    );
}

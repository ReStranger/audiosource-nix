{
  description = "Simple flake for build Audio Source";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsForSystem = system: import nixpkgs { inherit system; };
    in
    {
      formatter = forAllSystems (system: (pkgsForSystem system).nixfmt-tree);
      packages = forAllSystems (system: {
        audiosource = import ./nix/package.nix {
          inherit (pkgsForSystem system)
            stdenv
            lib
            pkgs
            fetchFromGitHub
            makeWrapper
            ;
        };
        default = self.packages.${system}.audiosource;
      });
      devShell = forAllSystems (
        system: with (pkgsForSystem system); {
          default = mkShell {
            inputsFrom = [ self.packages.${system}.default ];
            packages = [
              nixd
              nixfmt-tree
              bash-language-server
            ];
          };
        }
      );
    };
}

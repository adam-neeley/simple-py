{
  description = "A Nix-flake-based Python development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = { self, nixpkgs }:
    let
      supportedSystems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f:
        nixpkgs.lib.genAttrs supportedSystems (system:
          f {

            pkgs = import nixpkgs { inherit system; };
          });
    in {
      packages = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.python3Packages.buildPythonPackage {
          propogatedBuildInputs = with pkgs.python3Packages; [ setuptools ];
          pname = "adams-test";
          version = "0001";
          meta.mainProgram = "main.py";
          src = ./.;
        };
      });
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          venvDir = ".venv";
          packages = with pkgs;
            [ python311 ]
            ++ (with pkgs.python311Packages; [ pip venvShellHook ]);
        };
      });
    };
}

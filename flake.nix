{
  description = "Fan control tool for MSI gaming series laptops";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {self, ...}:
    inputs.flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import (inputs.nixpkgs) {
          inherit system;
        };
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "isw";
          version = "1.10";

          buildInputs = [pkgs.coreutils pkgs.python3];
          runtimeDependencies = [pkgs.python3];

          # src = pkgs.fetchFromGitHub {
          #   owner = "YoyPa";
          #   repo = "isw";
          #   rev = version;
          #   sha256 = "sha256-ZRHLhf0C3b5GhqlkZPBGooHL/UFfyfbp7XtPy9flz0k=";
          # };
          #
          src = ./.;

          installPhase = ''
            runHook preInstall
                  mkdir -p $out/etc
                  mkdir -p $out/etc/modprobe.d
                  mkdir -p $out/etc/modules-load.d
                  mkdir -p $out/usr/lib/systemd/system
                  mkdir -p $out/usr/bin
                  mkdir -p $out/bin

                  install -m755 etc/isw.conf $out/etc
                  install -m644 etc/modprobe.d/isw-ec_sys.conf $out/etc/modprobe.d/isw-ec_sys.conf
                  install -m644 etc/modules-load.d/isw-ec_sys.conf $out/etc/modules-load.d/isw-ec_sys.conf
                  install -m644 usr/lib/systemd/system/isw@.service $out/usr/lib/systemd/system
                  install -m755 isw $out/bin
            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Fan control tool for MSI gaming series laptops";
            license = licenses.gpl3;
            maintainers = [PostCyberPunk];
            platforms = platforms.linux;
            homepage = "https://github.com/YoyPa/isw";
          };
        };
      }
    );
}

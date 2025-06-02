{
  description = "Fan control tool for MSI gaming series laptops";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {self, ...}:
    inputs.flake-utils.lib.eachDefaultSystem (
      system: let
        #FIX: bab
        pkgs = import (inputs.nixpkgs) {
          inherit system;
        };
        pacakge = pkgs.stdenv.mkDerivation {
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
                  mkdir -p $out/bin

                  install -m600 etc/isw.conf $out/etc
                  install -m600 etc/modprobe.d/isw-ec_sys.conf $out/etc/modprobe.d/isw-ec_sys.conf
                  install -m600 etc/modules-load.d/isw-ec_sys.conf $out/etc/modules-load.d/isw-ec_sys.conf
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
      in {
        packages.default = pacakge;
        nixosModules.default = {
          config,
          lib,
          ...
        }: let
          cfg = config.services.isw;
        in {
          options = {
            services.isw = with lib; {
              enable = mkEnableOption "isw";
              section = mkOption {
                default = "";
                type = types.str;
                example = "16Q4EMS1";
                description = "Section name";
              };
            };
          };
          config = lib.mkIf cfg.enable {
            environment.systemPackages = [pacakge];
            environment.etc = {
              "isw.conf" = {
                source = "${pacakge}/etc/isw.conf";
                mode = "0600";
              };
              "modprobe.d/isw-ec_sys.conf" = {
                source = "${pacakge}/etc/modprobe.d/isw-ec_sys.conf";
                mode = "0600";
              };
              "modules-load.d/isw-ec_sys.conf" = {
                source = "${pacakge}/etc/modules-load.d/isw-ec_sys.conf";
                mode = "0600";
              };
            };
            systemd.services.isw = {
              unitConfig = {
                Description = "ISW fan control service";
                After = ["sleep.target"];
              };

              serviceConfig = lib.mkIf (cfg.section != "") {
                ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
                ExecStart = "${pacakge}/bin/isw -w ${cfg.section}";
                Type = "oneshot";
              };

              wantedBy = ["multi-user.target" "sleep.target"];
            };
            ######end of config
          };
        };
      }
    );
}

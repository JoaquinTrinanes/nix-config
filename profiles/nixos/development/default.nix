{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.profiles.development;
in
{
  options.profiles.development = {
    enable = lib.mkEnableOption "audio profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs)
        file
        git-extras
        hyperfine
        nixfmt-rfc-style
        pnpm
        scrcpy
        statix
        yarn-berry
        ;
      dbeaver-bin = lib.my.mkWrapper {
        basePackage = pkgs.dbeaver-bin;
        extraPackages = [ pkgs.gtk3 ];
        env.GDK_BACKEND.value = "x11";
      };
    };

    # includes android-tools
    programs.adb.enable = true;
  };
}

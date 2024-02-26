{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (builtins) fromJSON readFile toFile toJSON unsafeDiscardStringContext;
  inherit (lib) mkIf removePrefix;

  cfg = config.security.tpm2;
  tctiCfg = cfg.tctiEnvironment;
in {
  config = mkIf (cfg.enable && tctiCfg.enable) (
    let
      tctiOption =
        if tctiCfg.interface == "tabrmd"
        then tctiCfg.tabrmdConf
        else tctiCfg.deviceConf;
      pkg = pkgs.tpm2-tss;
      defaultCfgFile = pkg + /etc/tpm2-tss/fapi-config.json;
      defaultCfg =
        fromJSON (unsafeDiscardStringContext
          (readFile defaultCfgFile));
      tcti = "${tctiCfg.interface}:${tctiOption}";
      fixedCfg =
        defaultCfg
        // {
          inherit tcti;
          system_dir = removePrefix "${pkg}" defaultCfg.system_dir;
          log_dir = removePrefix "${pkg}" defaultCfg.log_dir;
        };
      fixedCfgFile = toFile "fapi-config.json" (toJSON fixedCfg);
    in {
      environment.variables = {
        TSS2_FAPICONF = fixedCfgFile;
        TPM2TOOLS_TCTI = tcti;
        TPM2_PKCS11_TCTI = tcti;
      };

      # programs.firefox.policies.SecurityDevices = {
      #   Add = {
      #     "OpenSC PKCS#11 Module" =
      #       # "/run/current-system/sw/lib/libtpm2_pkcs11.so";
      #       "${pkgs.opensc}/lib/opensc-pkcs11.so";
      #   };
      # };
    }
  );
}

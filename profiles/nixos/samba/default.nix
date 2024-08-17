{ config, lib, ... }:
let
  cfg = config.profiles.samba;
  # TODO: move all non-generic stuff outside or to an option
  path = "/mnt/media";
  publicPath = "${path}/Public";
  privatePath = "${path}/Private";
in
{

  options.profiles.samba = {
    enable = lib.mkEnableOption "samba profile";
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${path} 0755 media - - -"
      "d ${publicPath} 1777 media - - -"
      "d ${privatePath} 0700 media - - -"
    ];
    services.avahi = {
      enable = true;
    };
    services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
    services.samba = {
      enable = true;
      openFirewall = true;
      securityType = "user";
      extraConfig = ''
        # workgroup = WORKGROUP
        # server string = smbnix
        # netbios name = smbnix
        # use sendfile = yes
        # max protocol = smb2
        # note: localhost is the ipv6 localhost ::1
        hosts allow = 192.168.0. 127.0.0.1 localhost
        hosts deny = 0.0.0.0/0
        guest account = nobody
        map to guest = bad user
      '';
      shares = {
        public = {
          path = publicPath;
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          # "force user" = "username";
          # "force group" = "groupname";
        };
      };
    };
  };
}

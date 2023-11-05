{
  lib,
  pkgs,
  ...
}: {
  programs.direnv.enableNushellIntegration = lib.mkForce false;
  programs.nushell.extraConfig = ''
    $env.config = ($env.config | default {} hooks)
    $env.config = ($env.config | update hooks ($env.config.hooks | default {} env_change))
    $env.config = ($env.config | update hooks.env_change ($env.config.hooks.env_change | default [] PWD))
    $env.config = ($env.config | upsert hooks.pre_prompt ($env.config.hooks.pre_prompt? | default [] | append {||

    let direnv = (${pkgs.direnv}/bin/direnv export json | from json | default {})
    if ($direnv | is-empty) {
        return
    }

        $direnv
        | items {|key, value|
        {
                key: $key
                value: (if $key in $env.ENV_CONVERSIONS {
                    do ($env.ENV_CONVERSIONS | get $key | get from_string) $value
                    } else {
                        $value
                    }
        )
        }
        } | transpose -ird | load-env
    }))
  '';
}

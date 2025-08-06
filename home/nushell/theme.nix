{ config, lib, ... }:
let
  c = lib.mapAttrs (_: color: "#${color}") config.colors.palette;
in
{
  programs.nushell.extraConfig = ''
    export-env {
        let colors = {
            base00: "${c.base00}" # Default Background
            base01: "${c.base01}" # Lighter Background (Used for status bars, line number and folding marks)
            base02: "${c.base02}" # Selection Background
            base03: "${c.base03}" # Comments, Invisibles, Line Highlighting
            base04: "${c.base04}" # Dark Foreground (Used for status bars)
            base05: "${c.base05}" # Default Foreground, Caret, Delimiters, Operators
            base06: "${c.base06}" # Light Foreground (Not often used)
            base07: "${c.base07}" # Light Background (Not often used)
            base08: "${c.base08}" # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
            base09: "${c.base09}" # Integers, Boolean, Constants, XML Attributes, Markup Link Url
            base0a: "${c.base0A}" # Classes, Markup Bold, Search Text Background
            base0b: "${c.base0B}" # Strings, Inherited Class, Markup Code, Diff Inserted
            base0c: "${c.base0C}" # Support, Regular Expressions, Escape Characters, Markup Quotes
            base0d: "${c.base0D}" # Functions, Methods, Attribute IDs, Headings
            base0e: "${c.base0E}" # Keywords, Storage, Selector, Markup Italic, Diff Changed
            base0f: "${c.base0F}" # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
        }

        def relative_luminance [color] {
            def relative_luminance_helper [x: float] {
                if $x <= 0.03928 {
                    $x / 12.92
                } else {
                    ((($x + 0.055) / 1.055) ** 2.4)
                }
            }

            let rgb = $color
                | str trim -c '#' --left
                | split chars
                | window 2 --stride 2
                | each {str join}
                | into int --radix 16
                | each {|v| relative_luminance_helper ($v / 255) }

            let r = $rgb.0
            let b = $rgb.1
            let g = $rgb.2

            (0.2126 * $r) + (0.7152 * $g) + (0.0722 * $b)
        }

        def contrast [color1, color2] {
            let l1 = relative_luminance $color1
            let l2 = relative_luminance $color2

            let lighter = [$l1 $l2] | math max
            let darker = [$l1 $l2] | math min

            ($lighter + 0.05) / ($darker + 0.05)
        }


        let menu_style = {
            text: $colors.base05
            description_text: $colors.base07
            selected_text: { fg: $colors.base05 bg: $colors.base02 attr: b }
            match_text: { attr: u }
            selected_match_text: { bg: $colors.base02 attr: urb }
        }

        let theme_show_color = {|str|
            if $str =~ '^#[a-fA-F\d]{6}$' {
                let contrast00 = contrast $str $colors.base00
                let contrast05 = contrast $str $colors.base05

                { bg: $str fg: (if ($contrast00 > $contrast05) { $colors.base00 } else { $colors.base05 }) }
            } else {
                $colors.base06
            }
        }

        let theme = {
            separator: $colors.base03
            leading_trailing_space_bg: { bg: $colors.base04 }
            header: $colors.base0b
            date: {|| (date now) - $in |
                if $in < 1hr {
                    $colors.base0e
                } else if $in < 6hr {
                    $colors.base0a
                } else if $in < 1day {
                    $colors.base0b
                } else if $in < 3day {
                    $colors.base0c
                } else if $in < 1wk {
                    $colors.base0d
                } else if $in < 6wk {
                    $colors.base0e
                } else { $colors.base0f }
            }
            filesize: {||
                if $in == 0b {
                    $colors.base02
                } else if $in < 1mb {
                    $colors.base0c
                } else if $in > 0.5gb {
                    { fg: $colors.base08 attr: b }
                } else { $colors.base0d }
            }
            row_index: $colors.base0c
            bool: {|| if $in { $colors.base0d } else { $colors.base08 } }
            int: $colors.base0b
            duration: $colors.base08
            range: $colors.base08
            float: $colors.base08
            string: $theme_show_color
            nothing: $colors.base08
            binary: $colors.base08
            cellpath: $colors.base08
            hints: $colors.base02

            shape_garbage: { fg: $colors.base08 attr: u}
            shape_bool: $colors.base0d
            shape_int: { fg: $colors.base0e attr: b}
            shape_float: { fg: $colors.base0e attr: b}
            shape_range: { fg: $colors.base0a attr: b}
            shape_internalcall: { fg: $colors.base0c attr: b}
            shape_external: $colors.base0c
            shape_externalarg: { fg: $colors.base0b attr: b}
            shape_literal: $colors.base0d
            shape_operator: $colors.base0a
            shape_signature: { fg: $colors.base0b attr: b}
            shape_string: $colors.base0b
            shape_filepath: $colors.base0d
            shape_globpattern: { fg: $colors.base0d attr: b}
            shape_variable: $colors.base0e
            shape_flag: { fg: $colors.base0d attr: b}
            shape_custom: {attr: b}
        }

        $env.config.color_config = ($env.config.color_config | merge $theme)
        $env.config.menus = ($env.config.menus | each { update style { merge $menu_style } })
    }
  '';
}

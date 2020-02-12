# vim: set ts=2 sts=2 sw=2 et :
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ fontsize ? 18, codepage ? 2, bold ? false }:
{ config, pkgs, ... }:
{
  console =
  { font = "${pkgs.terminus_font}/share/consolefonts/ter-${toString codepage}${toString fontsize}${if bold then "b" else "n"}.psf.gz";
    keyMap = pkgs.writeText "us-two-alts" ''
      # us but with two alt keys
      keymaps 0-2,4-6,8-9,12
      alt_is_meta
      include "qwerty-layout"
      include "linux-with-two-alt-keys"
      include "compose.latin1"
      include "euro1.map"
      strings as usual

      keycode   1 = Escape
      keycode   2 = one              exclam
      keycode   3 = two              at               at               nul              nul
      keycode   4 = three            numbersign
      control	keycode   4 = Escape
      keycode   5 = four             dollar           dollar           Control_backslash
      keycode   6 = five             percent
      control	keycode   6 = Control_bracketright
      keycode   7 = six              asciicircum
      control	keycode   7 = Control_asciicircum
      keycode   8 = seven            ampersand        braceleft        Control_underscore
      keycode   9 = eight            asterisk         bracketleft      Delete
      keycode  10 = nine             parenleft        bracketright
      keycode  11 = zero             parenright       braceright
      keycode  12 = minus            underscore       backslash        Control_underscore Control_underscore
      keycode  13 = equal            plus
      keycode  14 = Delete
      keycode  15 = Tab
      shift	keycode  15 = Meta_Tab
      keycode  26 = bracketleft      braceleft
      control	keycode  26 = Escape
      keycode  27 = bracketright     braceright       asciitilde       Control_bracketright
      keycode  28 = Return
      alt	keycode  28 = Meta_Control_m
      keycode  29 = Control
      keycode  39 = semicolon        colon
      keycode  40 = apostrophe       quotedbl
      control	keycode  40 = Control_g
      keycode  41 = grave            asciitilde
      control	keycode  41 = nul
      keycode  42 = Shift
      keycode  43 = backslash        bar
      control	keycode  43 = Control_backslash
      keycode  51 = comma            less
      keycode  52 = period           greater
      keycode  53 = slash            question
      control keycode  53 = Control_underscore
      control shift keycode  53 = Delete
      keycode  54 = Shift
      keycode  56 = Alt
      keycode  57 = space
      control	keycode  57 = nul
      keycode  58 = Caps_Lock
      keycode  86 = less             greater          bar
      keycode  97 = Control
      keycode 100 = Alt
    '' ;
  };
}

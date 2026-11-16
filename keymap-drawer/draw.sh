#!/usr/bin/env sh
# Regenerate keymap-drawer/keymap.svg from config/halcyon_ferris.keymap.
# The keymap has 44 positions per layer (34 keys + the Halcyon module row);
# the drawing drops the module row and uses the plain 34-key Ferris layout.
set -eu
cd "$(dirname "$0")/.."
d=keymap-drawer

uvx --from keymap-drawer keymap -c $d/config.yaml parse -z config/halcyon_ferris.keymap > $d/keymap.yaml

# Keep only the first 34 items of each layer list (layers come before "combos:").
awk '
  /^combos:/          { in_layers = 0 }
  /^layers:/          { in_layers = 1; print; next }
  in_layers && /^  [^ -].*:$/ { n = 0; print; next }
  in_layers && /^  - / { n++; if (n <= 34) print; next }
  { print }
' $d/keymap.yaml > $d/keymap.yaml.tmp && mv $d/keymap.yaml.tmp $d/keymap.yaml

uvx --from keymap-drawer keymap -c $d/config.yaml draw \
  -d $d/halcyon_ferris-layouts.dtsi -l splitkb_halcyon_ferris \
  $d/keymap.yaml > $d/keymap.svg

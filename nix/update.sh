#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix
# This script updates the npm package dependency versions
node2nix -8 -i node-packages.json


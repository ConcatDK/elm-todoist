{pkgs ? import ./nix/packages.nix}:
with pkgs;
stdenv.mkDerivation {
    name = "block-script";
    buildInputs = [
        elmPackages.elm
        elmPackages.elm-format
        elmPackages.elm-test
        elmPackages.elm-live
        nodejs-8_x #Required for elm-live
    ];
}


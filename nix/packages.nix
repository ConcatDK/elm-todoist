with import ( fetchTarball {
  url = https://github.com/NixOS/nixpkgs-channels/archive/a4c4cbb613cc3e15186de0fdb04082fa7e38f6a0.tar.gz;
}) {};
with pkgs;
let
  custom = import ./default.nix {};
  elm-test = custom."elm-test-elm0.19.0".override {
    buildInputs = [ custom.binwrap gmp5 ];
    postInstall = ''
      patchelf \
          --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "${gmp5}/lib" \
          "$out/lib/node_modules/elm-test/node_modules/elmi-to-json/unpacked_bin/elmi-to-json"
    '';
  };
  elm-format = custom."elm-format".override {
    buildInputs = [ gmp5 ];
    postInstall = ''
      patchelf \
          --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "${gmp5}/lib" \
          "$out/lib/node_modules/elm-format/unpacked_bin/elm-format"
    '';
  };
  elm-live = custom."elm-live".override {
    buildInputs = [ nodejs-8_x ];
  };
in
pkgs // {
  elmPackages = elmPackages // {
    elm-test = elm-test;
    elm-live = elm-live;
    elm-format = elm-format;
  };
}

FROM nixos/nix
ADD nix ./nix
RUN nix-env -f nix/packages.nix -iA \
        elmPackages.elm \
        elmPackages.elm-format \
        elmPackages.elm-test \
  && nix-collect-garbage -d \
  && nix-store --optimise
WORKDIR /code
ADD elm.json ./
ADD src ./src
ADD tests ./tests
RUN elm make src/Main.elm --output=public/elm.js

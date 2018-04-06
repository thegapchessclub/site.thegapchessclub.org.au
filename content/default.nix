{ nixpkgs ? import <nixpkgs> {}
, generator ? import ../generator
}:
let
  inherit (nixpkgs) pkgs;

  mytexlive = (pkgs.texlive.combine {
    inherit (pkgs.texlive)
    prftree
    scheme-basic
    collection-latexrecommended
    collection-mathextra;
  });

  activate = pkgs.writeScriptBin "activate" ''
    #!${pkgs.bash}/bin/bash -e

    '';

in
  pkgs.stdenv.mkDerivation {
    name = "blog-content";
    src = ./.;

    unpackPhase = ''
      cp -r $src/* .
      chmod -R +w .

    '';

    buildPhase = ''
      export LANG=en_US.UTF-8
      export LOCALE_ARCHIVE=/run/current-system/sw/lib/locale/locale-archive
      site build
    '';

    installPhase = ''
      mkdir -p $out/blog
      cp -r _site/* $out/blog/
      mkdir -p $out/bin
      ln -sv ${activate}/bin/activate $out/bin/
    '';

    phases = ["unpackPhase" "buildPhase" "installPhase"];

    buildInputs = [generator mytexlive pkgs.imagemagick pkgs.ghostscript pkgs.glibcLocales];
  }



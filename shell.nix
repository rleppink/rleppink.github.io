with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "rleppink-github-io";
  buildInputs = [ ghc stack ];
}

{ mkDerivation, base, filepath, hakyll, stdenv, time }:
mkDerivation {
  pname = "rleppink-github-io";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base filepath hakyll time ];
  license = stdenv.lib.licenses.unfree;
  hydraPlatforms = stdenv.lib.platforms.none;
}

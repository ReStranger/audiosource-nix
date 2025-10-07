{
  stdenv,
  lib,
  pkgs,
  fetchFromGitHub,
  makeWrapper,
}:
let
  runtimeBins = with pkgs; [
    android-tools
    python312
    pulseaudio
  ];
  runtimePath = builtins.concatStringsSep ":" (map (pkg: "${pkg}/bin") runtimeBins);

in
stdenv.mkDerivation (finalAttrs: {
  pname = "audiosource";
  version = "1.4";
  outputs = [
    "out"
  ];
  src = fetchFromGitHub {
    owner = "gdzx";
    repo = "audiosource";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SlX8gjs7X5jfoeU6pyk4n8f6oMJgneGVt0pmFs48+mQ=";
  };
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 audiosource $out/bin/audiosource
    runHook postInstall
  '';
  postInstall = ''
    wrapProgram $out/bin/audiosource \
        --prefix PATH : "${runtimePath}"
  '';
  meta = with lib; {
    description = "Use an Android device as a USB microphone";
    mainProgram = "audiosource";
    homepage = "https://github.com/gdzx/audiosource";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ "ReStranger" ];
  };
})

{ lib
, stdenv
, fetchFromSourcehut
, qbe
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "harec";
  version = "unstable-2023-06-10";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = "harec";
    rev = "f5da14c17f734f0bba5a741997b79d3e65a87712";
    hash = "sha256-1o/ybHSVb4fXsnqPQFg35yMq7Z0YGr4f7LsVz9tNrvU=";
  };

  nativeBuildInputs = [
    qbe
  ];

  buildInputs = [
    qbe
  ];

  # TODO: report upstream
  hardeningDisable = [ "fortify" ];

  strictDeps = true;

  doCheck = true;

  meta = {
    homepage = "http://harelang.org/";
    description = "Bootstrapping Hare compiler written in C for POSIX systems";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.AndersonTorres ];
    # The upstream developers do not like proprietary operating systems; see
    # https://harelang.org/platforms/
    platforms = with lib.platforms;
      lib.intersectLists (freebsd ++ linux) (aarch64 ++ x86_64 ++ riscv64);
    badPlatforms = lib.platforms.darwin;
  };
})

{ lib
, stdenv
, fetchFromGitHub
, cmake
, ninja
, unzip
, wrapQtAppsHook
, libxcrypt
, qt6
, nixosTests
}:

stdenv.mkDerivation {
  pname = "ladybird";
  version = "unstable-2023-06-29";

  src = fetchFromGitHub {
    owner = "SerenityOS";
    repo = "serenity";
    rev = "5bc2c333bdfec7d5363968e01d4df2e175995ca1";
    hash = "sha256-N1pM4oZEcPxWykcc3IQB5OkpX1ZQvHs1cFeTfmnXyfU=";
  };

  sourceRoot = "source/Ladybird";

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "MACOSX_BUNDLE TRUE" "MACOSX_BUNDLE FALSE"
    # https://github.com/SerenityOS/serenity/issues/17062
    substituteInPlace main.cpp \
      --replace "./SQLServer/SQLServer" "$out/bin/SQLServer"
    # https://github.com/SerenityOS/serenity/issues/10055
    substituteInPlace ../Meta/Lagom/CMakeLists.txt \
      --replace "@rpath" "$out/lib"
  '';

  nativeBuildInputs = [
    cmake
    ninja
    unzip
    wrapQtAppsHook
  ];

  buildInputs = [
    libxcrypt
    qt6.qtbase
    qt6.qtsvg
    qt6.qtmultimedia
  ];

  cmakeFlags = [
    # Disable network operations
    "-DENABLE_TIME_ZONE_DATABASE_DOWNLOAD=false"
    "-DENABLE_UNICODE_DATABASE_DOWNLOAD=false"
    "-DENABLE_CACERT_DOWNLOAD=false"
  ];

  patchFlags = "-p2";

  patches = [
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error";

  # https://github.com/SerenityOS/serenity/issues/10055
  postInstall = lib.optionalString stdenv.isDarwin ''
    install_name_tool -add_rpath $out/lib $out/bin/ladybird
  '';

  passthru.tests = {
    nixosTest = nixosTests.ladybird;
  };

  meta = with lib; {
    description = "A browser using the SerenityOS LibWeb engine with a Qt GUI";
    homepage = "https://github.com/awesomekling/ladybird";
    license = licenses.bsd2;
    maintainers = with maintainers; [ fgaz ];
    platforms = platforms.unix;
  };
}

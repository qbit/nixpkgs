{ pkgs
, lib
, coreutils
, fetchgit
#, fetchurl
, git
, installShellFiles
, perl
, perlPackages
, rsync
, which
, lsb-release
, ... }:

#perlPackages.buildPerlPackage rec {
perlPackages.buildPerlPackage {
  pname = "Rex";
  version = "1.14.1";
  #src = fetchurl {
  #  url = "mirror://cpan/authors/id/F/FE/FERKI/Rex-${version}.tar.gz";
  #  sha256 = "a86e9270159b41c9a8fce96f9ddc97c5caa68167ca4ed33e97908bfce17098cf";
  #};
  src = fetchgit {
    name = "Rex";
    url = "https://github.com/RexOps/Rex";
    branchName = "nixos";
    rev = "00e9eff29583b0e0dd32a01ca79b67f555e9c009";
    hash = "sha256-VoCUILPgugfu/1w8Ch8XLJG6ETWd4RyIpwC0Yso4oh8=";
  };

  buildInputs = with perlPackages; [
    FileShareDirInstall
    ParallelForkManager
    StringEscape
    SubOverride
    TestDeep
    TestException
    TestOutput
    TestUseAllModules
    TestWarnings

    git
    perl
    rsync
    which
  ];

  nativeBuildInputs = with perlPackages; [
    installShellFiles
    ParallelForkManager
  ];

  propagatedBuildInputs = with perlPackages; [
    AWSSignature4
    DataValidateIP
    DevelCaller
    DigestHMAC
    FileLibMagic
    HashMerge
    HTTPMessage
    IOPty
    IOString
    JSONMaybeXS
    LWP
    NetOpenSSH
    NetSFTPForeign
    SortNaturally
    TermReadKey
    TextGlob
    URI
    XMLSimple
    YAML
  ];

  prePatch = ''
    touch Makefile.PL
  '';

  checkInputs = [
    coreutils
    git
    perl
    rsync
    which
  ];

  doCheck = true;
  checkPhase = ''
    echo "PATH: $PATH"
    echo "RSYNC: $(which rsync)"
    echo "GIT $(which git)"
    echo "PERL $(which perl)"
    echo "UNAME $(which uname)"
    exit 1
    runHook preCheck
    prove -lr t/
    runHook postCheck
  '';

  outputs = [ "out" ];

  fixupPhase = ''
    for sh in bash zsh; do
      substituteInPlace ./share/rex-tab-completion.$sh \
        --replace 'perl' "${pkgs.perl.withPackages (ps: [ ps.YAML ])}/bin/perl"
    done
    installShellCompletion --name _rex --zsh ./share/rex-tab-completion.zsh
    installShellCompletion --name rex --bash ./share/rex-tab-completion.bash
  '';

  meta = {
    homepage = "https://www.rexify.org";
    description = "The friendly automation framework";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ qbit ];
  };
}

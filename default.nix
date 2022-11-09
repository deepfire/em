/*
This is a nix expression to build Emacs and some Emacs packages I like
from source on any distribution where Nix is installed. This will install
all the dependencies from the nixpkgs repository and build the binary files
without interfering with the host distribution.

To build the project, type the following from the current directory:

$ nix-build

*/
let version = "2022.1109.0";
in

{ useHostNixpkgs ? false
, sources        ? import ./nix/sources.nix { inherit pkgs; }
, nixpkgsSrcs    ? if !useHostNixpkgs then sources.nixpkgs     else <nixpkgs>
, nixpkgsRev     ? if !useHostNixpkgs then sources.nixpkgs.rev else "HOST"
, pkgs           ? import nixpkgsSrcs {}
, font           ? "TerminessTTF Nerd Font"
}:

let
  fromGithub  = old: owner: repo: rev: sha256:
    (old.override (args:
      { melpaBuild = drv: args.melpaBuild (drv // {
          src = pkgs.fetchFromGitHub { inherit owner repo rev sha256; }; });}));

  mkEmacsWithPackages = (pkgs.emacsPackagesFor pkgs.emacs).emacsWithPackages;

  emacs = mkEmacsWithPackages (epkgs: (with epkgs.elpaPackages; [
  ]) ++ (with epkgs.melpaPackages; [
    ag
    all-the-icons
    boxquote
    color-theme-modern
    dante
    # (fromGithub dante "jyp" "dante" "9289b6f053f343cb841ea7ca74758fe41bf6b74c" "1x36ck1wy19rlqfzcdy2xs888iqs1r1vkllnx8ld4z4aak1sg2mj")
    dumb-jump
    flycheck
    form-feed
    git-auto-commit-mode
    git-gutter-fringe
    gnuplot
    haskell-mode
    hasklig-mode
    helm
    helm-ag
    helm-ag-r
    helm-cmd-t
    helm-descbinds
    helm-grepint
    helm-helm-commands
    helm-hoogle
    helm-ls-git
    htmlize
    jq-mode
    magit
    magit-popup
    markdown-mode
    neotree
    nix-mode
    nixos-options
    paredit
    paren-face
    quelpa
    s
    solarized-theme
    strace-mode
    sudo-edit
    use-package
    which-key
  ]) ++ (with epkgs.nongnuPackages; [
    org-contrib
  ]));

  bundled-emacs-init = ./init.el;

  extra-emacs-args =
    [ "--no-init-file"
      "--load=${bundled-emacs-init}"
      "-fn" "'${font}'"
      "-bg" "'#002b36'"
      "-fg" "'#839496'"
    ];
in

with pkgs;

stdenv.mkDerivation rec {
  inherit version;
  name = "em-${version}";

  src = ./.;

  nativeBuildInputs = [
    makeWrapper

    ## Fonts:
    aurulent-sans
    terminus_font
    nerdfonts
    terminus_font_ttf
    gnuplot
  ];

  installPhase =
  ''
    mkdir -p $out/bin

    makeWrapper ${emacs}/bin/emacs $out/bin/em \
      --run "echo '${name}: nixpkgs commit ${nixpkgsRev}'" \
      --run "echo '${name}: loading bundled init.el: ${bundled-emacs-init}'" \
      --add-flags "${toString extra-emacs-args}" \
      --prefix PATH : ${lib.makeBinPath
        [ gnuplot
          texlive.combined.scheme-full
        ]}

    cat >$out/bin/emn <<EOF
    echo '${name}: nixpkgs commit ${nixpkgsRev}'
    echo '${name}: loading bundled init.el: ${bundled-emacs-init}'
    nohup $out/bin/em "\$@" </dev/null 2>/dev/null &
    sleep 0.1
    rm -f nohup.out
    EOF
    chmod +x $out/bin/emn
  '';
}

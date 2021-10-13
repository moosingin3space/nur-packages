{ stdenv, lib, deno, fetchFromGitHub }:

let 
  denoEnv = import ../deno-packages/deno-env.nix {
    inherit stdenv deno;
  };
in
denoEnv.buildDenoBinary {
  pname = "velociraptor";
  version = "1.2.0";
  lockfile = ./lock.json;
  depSha256 = "sha256-t/C9h3A6QIHquMs5eXbmEXINaEmKwE6HLzjomeraAao=";
  denoOpts = "-A";

  src = fetchFromGitHub {
    owner = "jurassiscripts";
    repo = "velociraptor";
    rev = "acb9e6eb5c1bbf84e9f7b0c4c5d46222f61df279";
    sha256 = "sh4LnzLa0TL0KaL8lAsiWl90pKJvmphGf4u4PncGvww=";
  };

  entrypoint = "./cli.ts";
  binname = "vr";
}
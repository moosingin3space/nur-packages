{ stdenv, deno }:

let 
    vendoredDenoDeps = { pname, src, entrypoint, lockfile, sha256 }:
    let
        normalizeScript = ./normalize-metadata-files.ts;
    in
    stdenv.mkDerivation {
        name = "${pname}-deno-deps.tar.gz";
        nativeBuildInputs = [ deno ];
        inherit src;

        phases = "unpackPhase patchPhase buildPhase installPhase";
        buildPhase = ''
        export SOURCE_DATE_EPOCH=1
        mkdir -p denodir
        DENO_DIR=denodir deno cache --lock ${lockfile} ${entrypoint}

        # We now clear out .metadata.json files since those include non-reproducible
        # information in them, like the time of the HTTP request made.
        find ./denodir/deps -type f -name '*.metadata.json' -print -exec deno run --allow-read --allow-write ${normalizeScript} {} \;
        '';
        installPhase = ''
            tar --owner=0 --group=0 --numeric-owner --format=gnu \
                --sort=name --mtime="@$SOURCE_DATE_EPOCH" \
                -czf $out denodir/deps/ denodir/gen/
        '';

        outputHashAlgo = "sha256";
        outputHash = sha256;
    };

    buildDenoBinary = { entrypoint, binname, pname, lockfile, depSha256, version, src,
    denoOpts ? "" }:
    let 
        denoDeps = vendoredDenoDeps {
            inherit pname;
            inherit src;
            entrypoint = "${src}/${entrypoint}";
            inherit lockfile;
            sha256 = depSha256;
        };
    in
    stdenv.mkDerivation {
        inherit pname version src;
        nativeBuildInputs = [ deno ];

        dontStrip = true;

        postUnpack = ''
            tar -xvf ${denoDeps} -C $sourceRoot
        '';

        buildPhase = ''
            DENO_DIR=$PWD/denodir deno info
            DENO_DIR=$PWD/denodir deno compile --cached-only --lock ${lockfile} --output ${binname} ${denoOpts} ${entrypoint}
        '';
        installPhase = ''
            mkdir -p $out/bin
            install -t $out/bin ${binname}
        '';
    };
in {
    inherit buildDenoBinary;
}
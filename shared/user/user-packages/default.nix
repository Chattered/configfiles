{
  packages = {
    ocaml_tophook =
      let
        safeX11 = stdenv: !(stdenv.isArm || stdenv.isMips);
      in

      { stdenv, fetchFromGitHub, ncurses, buildEnv, libX11, xproto,
        useX11 ? safeX11 stdenv }:

      if useX11 && !(safeX11 stdenv)
        then throw "x11 not available in ocaml with arm or mips arch"
        else # let the indentation flow

      let
         useNativeCompilers = !stdenv.isMips;
         inherit (stdenv.lib) optionals optionalString;
      in

      stdenv.mkDerivation rec {

        x11env = buildEnv { name = "x11env"; paths = [libX11 xproto]; };
        x11lib = x11env + "/lib";
        x11inc = x11env + "/include";

        name = "ocaml-4.01.0-tophook";

        src = fetchFromGitHub {
          owner = "Chattered";
          repo = "ocaml";
          rev = "toploop_hook";
          sha256 = "15f36riy031j7dp6wzcvyc5vyx3g400nh9pq875mj38md7xk6dba";
        };

        prefixKey = "-prefix ";
        configureFlags = ["-no-tk"] ++ optionals useX11 [ "-x11lib" x11lib
                                                          "-x11include" x11inc ];

        buildFlags =
          "world" + optionalString useNativeCompilers " bootstrap world.opt";
        buildInputs = [ncurses] ++ optionals useX11 [ libX11 xproto ];
        installTargets = "install" + optionalString useNativeCompilers " installopt";
        preConfigure = ''
          CAT=$(type -tp cat)
          sed -e "s@/bin/cat@$CAT@" -i config/auto-aux/sharpbang
        '';
        postBuild = ''
          mkdir -p $out/include
          ln -sv $out/lib/ocaml/caml $out/include/caml
        '';

        passthru = {
          nativeCompilers = useNativeCompilers;
        };

        meta = with stdenv.lib; {
          homepage = http://caml.inria.fr/ocaml;
          branch = "4.01";
          license = with licenses; [
            qpl /* compiler */
            lgpl2 /* library */
          ];
          description = "Most popular variant of the Caml language";

          longDescription =
            ''
              OCaml is the most popular variant of the Caml language.  From a
              language standpoint, it extends the core Caml language with a
              fully-fledged object-oriented layer, as well as a powerful module
              system, all connected by a sound, polymorphic type system featuring
              type inference.

              The OCaml system is an industrial-strength implementation of this
              language, featuring a high-performance native-code compiler (ocamlopt)
              for 9 processor architectures (IA32, PowerPC, AMD64, Alpha, Sparc,
              Mips, IA64, HPPA, StrongArm), as well as a bytecode compiler (ocamlc)
              and an interactive read-eval-print loop (ocaml) for quick development
              and portability.  The OCaml distribution includes a comprehensive
              standard library, a replay debugger (ocamldebug), lexer (ocamllex) and
              parser (ocamlyacc) generators, a pre-processor pretty-printer (camlp4)
              and a documentation generator (ocamldoc).
            '';

          platforms = with platforms; linux ++ darwin;
        };
    };
    hol =
      { stdenv, fetchurl, polyml }:
      stdenv.mkDerivation {

      name = "hol4";

      # src = fetchFromGitHub {
      #   owner = "HOL-Theorem-Prover";
      #   repo = "HOL";
      #   rev = "kananaskis-10";
      #   sha256 = "08kca56kii07fnp6b1xrzcrmdv8i7sm49sc7vff38ik4sc5k5z6w";
      # };

      src = fetchurl {
        url = "https://github.com/HOL-Theorem-Prover/HOL/archive/kananaskis-10.tar.gz";
        sha256 = "1agnqgjfhn3bbv9nq7zmr8684fmw3bbzfhx0sy09xnjkc0167kza";
      };

      buildCommand = ''
        mkdir -p $out/src
        cd  $out/src
        tar -xzf $src
        cd HOL-kananaskis-10

        sed -e "s@/bin/cp@/run/current-system/sw/bin/cp@"\
            -i tools/Holmake/Holmake_types.sml
        sed -e "s@/bin/mv@/run/current-system/sw/bin/mv@"\
            -i tools/Holmake/Holmake_types.sml

        ${polyml}/bin/poly < tools/smart-configure.sml

        bin/build -symlink

        mkdir -p $out/bin
      '';

      meta = with stdenv.lib; {
        homepage = https://hol-theorem-prover.org/;
        license = licenses.bsd3;
        description = "The HOL 4 theorem prover";
        platform = linux;
      };
    };
  };
  ocamlPackages = import ./ocaml-packages.nix;
  haskellPackages = import ./haskell-packages.nix;
}

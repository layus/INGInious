# generated using pypi2nix tool (version: 2.0.0)
# See more at: https://github.com/nix-community/pypi2nix
#
# COMMAND:
#   pypi2nix -V 3.7 -v -r requirements.txt -e lxml -E libxml2 -E libxslt -E openssl -e setuptools-scm
#

{ pkgs ? import <nixpkgs> {},
  overrides ? ({ pkgs, python }: self: super: {})
}:

let

  inherit (pkgs) makeWrapper;
  inherit (pkgs.stdenv.lib) fix' extends inNixShell;

  pythonPackages =
  import "${toString pkgs.path}/pkgs/top-level/python-packages.nix" {
    inherit pkgs;
    inherit (pkgs) stdenv;
    python = pkgs.python37;
    # patching pip so it does not try to remove files when running nix-shell
    overrides =
      self: super: {
        bootstrapped-pip = super.bootstrapped-pip.overrideDerivation (old: {
          patchPhase = old.patchPhase + ''
            if [ -e $out/${pkgs.python37.sitePackages}/pip/req/req_install.py ]; then
              sed -i \
                -e "s|paths_to_remove.remove(auto_confirm)|#paths_to_remove.remove(auto_confirm)|"  \
                -e "s|self.uninstalled = paths_to_remove|#self.uninstalled = paths_to_remove|"  \
                $out/${pkgs.python37.sitePackages}/pip/req/req_install.py
            fi
          '';
        });
      };
  };

  commonBuildInputs = with pkgs; [ libxml2 libxslt openssl ];
  commonDoCheck = false;

  withPackages = pkgs':
    let
      pkgs = builtins.removeAttrs pkgs' ["__unfix__"];
      interpreterWithPackages = selectPkgsFn: pythonPackages.buildPythonPackage {
        name = "python37-interpreter";
        buildInputs = [ makeWrapper ] ++ (selectPkgsFn pkgs);
        buildCommand = ''
          mkdir -p $out/bin
          ln -s ${pythonPackages.python.interpreter} \
              $out/bin/${pythonPackages.python.executable}
          for dep in ${builtins.concatStringsSep " "
              (selectPkgsFn pkgs)}; do
            if [ -d "$dep/bin" ]; then
              for prog in "$dep/bin/"*; do
                if [ -x "$prog" ] && [ -f "$prog" ]; then
                  ln -s $prog $out/bin/`basename $prog`
                fi
              done
            fi
          done
          for prog in "$out/bin/"*; do
            wrapProgram "$prog" --prefix PYTHONPATH : "$PYTHONPATH"
          done
          pushd $out/bin
          ln -s ${pythonPackages.python.executable} python
          ln -s ${pythonPackages.python.executable} \
              python3
          popd
        '';
        passthru.interpreter = pythonPackages.python;
      };

      interpreter = interpreterWithPackages builtins.attrValues;
    in {
      __old = pythonPackages;
      inherit interpreter;
      inherit interpreterWithPackages;
      mkDerivation = args: pythonPackages.buildPythonPackage (args // {
        nativeBuildInputs = (args.nativeBuildInputs or []) ++ args.buildInputs;
      });
      packages = pkgs;
      overrideDerivation = drv: f:
        pythonPackages.buildPythonPackage (
          drv.drvAttrs // f drv.drvAttrs // { meta = drv.meta; }
        );
      withPackages = pkgs'':
        withPackages (pkgs // pkgs'');
    };

  python = withPackages {};

  generated = self: {
    "asn1crypto" = python.mkDerivation {
      name = "asn1crypto-0.24.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/fc/f1/8db7daa71f414ddabfa056c4ef792e1461ff655c2ae2928a2b675bfed6b4/asn1crypto-0.24.0.tar.gz";
        sha256 = "9d5c20441baf0cb60a4ac34cc447c6c189024b6b4c6cd7877034f4965c464e49";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/wbond/asn1crypto";
        license = licenses.mit;
        description = "Fast ASN.1 parser and serializer with definitions for private keys, public keys, certificates, CRL, OCSP, CMS, PKCS#3, PKCS#7, PKCS#8, PKCS#12, PKCS#5, X.509 and TSP";
      };
    };

    "bcrypt" = python.mkDerivation {
      name = "bcrypt-3.1.7";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/fa/aa/025a3ab62469b5167bc397837c9ffc486c42a97ef12ceaa6699d8f5a5416/bcrypt-3.1.7.tar.gz";
        sha256 = "0b0069c752ec14172c5f78208f1863d7ad6755a6fae6fe76ec2c80d13be41e42";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [
        self."cffi"
      ];
      propagatedBuildInputs = [
        self."cffi"
        self."six"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyca/bcrypt/";
        license = licenses.asl20;
        description = "Modern password hashing for your software and your servers";
      };
    };

    "certifi" = python.mkDerivation {
      name = "certifi-2019.6.16";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/c5/67/5d0548226bcc34468e23a0333978f0e23d28d0b3f0c71a151aef9c3f7680/certifi-2019.6.16.tar.gz";
        sha256 = "945e3ba63a0b9f577b1395204e13c3a231f9bc0223888be653286534e5873695";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://certifi.io/";
        license = licenses.mpl20;
        description = "Python package for providing Mozilla's CA Bundle.";
      };
    };

    "cffi" = python.mkDerivation {
      name = "cffi-1.12.3";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/93/1a/ab8c62b5838722f29f3daffcc8d4bd61844aa9b5f437341cc890ceee483b/cffi-1.12.3.tar.gz";
        sha256 = "041c81822e9f84b1d9c401182e174996f0bae9991f33725d059b771744290774";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."pycparser"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://cffi.readthedocs.org";
        license = licenses.mit;
        description = "Foreign Function Interface for Python calling C code.";
      };
    };

    "chardet" = python.mkDerivation {
      name = "chardet-3.0.4";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz";
        sha256 = "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/chardet/chardet";
        license = licenses.lgpl3;
        description = "Universal encoding detector for Python 2 and 3";
      };
    };

    "cryptography" = python.mkDerivation {
      name = "cryptography-2.7";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/c2/95/f43d02315f4ec074219c6e3124a87eba1d2d12196c2767fadfdc07a83884/cryptography-2.7.tar.gz";
        sha256 = "e6347742ac8f35ded4a46ff835c60e68c22a536a8ae5c4422966d06946b6d4c6";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [
        self."cffi"
      ];
      propagatedBuildInputs = [
        self."asn1crypto"
        self."cffi"
        self."idna"
        self."six"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyca/cryptography";
        license = licenses.bsdOriginal;
        description = "cryptography is a package which provides cryptographic recipes and primitives to Python developers.";
      };
    };

    "docker" = python.mkDerivation {
      name = "docker-4.0.2";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/6a/81/425eb2011e53b20e5245489ff02f27d434b165746831daf26f755402fa6c/docker-4.0.2.tar.gz";
        sha256 = "cc5b2e94af6a2b1e1ed9d7dcbdc77eff56c36081757baf9ada6e878ea0213164";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."cryptography"
        self."idna"
        self."paramiko"
        self."pyopenssl"
        self."requests"
        self."six"
        self."websocket-client"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/docker/docker-py";
        license = licenses.asl20;
        description = "A Python library for the Docker Engine API.";
      };
    };

    "idna" = python.mkDerivation {
      name = "idna-2.8";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ad/13/eb56951b6f7950cadb579ca166e448ba77f9d24efc03edd7e55fa57d04b7/idna-2.8.tar.gz";
        sha256 = "c357b3f628cf53ae2c4c05627ecc484553142ca23264e593d327bcde5e9c3407";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/kjd/idna";
        license = licenses.bsdOriginal;
        description = "Internationalized Domain Names in Applications (IDNA)";
      };
    };

    "lxml" = python.mkDerivation {
      name = "lxml-4.3.3";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/7d/29/174d70f303016c58bd790c6c86e6e86a9d18239fac314d55a9b7be501943/lxml-4.3.3.tar.gz";
        sha256 = "4a03dd682f8e35a10234904e0b9508d705ff98cf962c5851ed052e9340df3d90";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://lxml.de/";
        license = licenses.bsdOriginal;
        description = "Powerful and Pythonic XML processing library combining libxml2/libxslt with the ElementTree API.";
      };
    };

    "packaging" = python.mkDerivation {
      name = "packaging-19.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/16/51/d72654dbbaa4a4ffbf7cb0ecd7d12222979e0a660bf3f42acc47550bf098/packaging-19.0.tar.gz";
        sha256 = "0c98a5d0be38ed775798ece1b9727178c4469d9c3b4ada66e8e6b7849f8732af";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."pyparsing"
        self."six"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pypa/packaging";
        license = licenses.bsdOriginal;
        description = "Core utilities for Python packages";
      };
    };

    "paramiko" = python.mkDerivation {
      name = "paramiko-2.6.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/54/68/dde7919279d4ecdd1607a7eb425a2874ccd49a73a5a71f8aa4f0102d3eb8/paramiko-2.6.0.tar.gz";
        sha256 = "f4b2edfa0d226b70bd4ca31ea7e389325990283da23465d572ed1f70a7583041";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."bcrypt"
        self."cryptography"
        self."pyasn1"
        self."pynacl"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/paramiko/paramiko/";
        license = licenses.lgpl3;
        description = "SSH2 protocol library";
      };
    };

    "py" = python.mkDerivation {
      name = "py-1.7.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/c7/fa/eb6dd513d9eb13436e110aaeef9a1703437a8efa466ce6bb2ff1d9217ac7/py-1.7.0.tar.gz";
        sha256 = "bf92637198836372b520efcba9e020c330123be8ce527e535d185ed4b6f45694";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://py.readthedocs.io/";
        license = licenses.mit;
        description = "library with cross-python path, ini-parsing, io, code, log facilities";
      };
    };

    "pyasn1" = python.mkDerivation {
      name = "pyasn1-0.4.5";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/46/60/b7e32f6ff481b8a1f6c8f02b0fd9b693d1c92ddd2efb038ec050d99a7245/pyasn1-0.4.5.tar.gz";
        sha256 = "da2420fe13a9452d8ae97a0e478adde1dee153b11ba832a95b223a2ba01c10f7";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/etingof/pyasn1";
        license = licenses.bsdOriginal;
        description = "ASN.1 types and codecs";
      };
    };

    "pycparser" = python.mkDerivation {
      name = "pycparser-2.19";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/68/9e/49196946aee219aead1290e00d1e7fdeab8567783e83e1b9ab5585e6206a/pycparser-2.19.tar.gz";
        sha256 = "a988718abfad80b6b157acce7bf130a30876d27603738ac39f140993246b25b3";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/eliben/pycparser";
        license = licenses.bsdOriginal;
        description = "C parser in Python";
      };
    };

    "pymongo" = python.mkDerivation {
      name = "pymongo-3.7.2";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/0f/3a/b90cfa7e27fa92244925826538fa2cf80fed3cbd20a413fd0c1b9705d820/pymongo-3.7.2.tar.gz";
        sha256 = "8c74e2a9b594f7962c62cef7680a4cb92a96b4e6e3c2f970790da67cc0213a7e";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/mongodb/mongo-python-driver";
        license = licenses.asl20;
        description = "Python driver for MongoDB <http://www.mongodb.org>";
      };
    };

    "pynacl" = python.mkDerivation {
      name = "pynacl-1.3.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/61/ab/2ac6dea8489fa713e2b4c6c5b549cc962dd4a842b5998d9e80cf8440b7cd/PyNaCl-1.3.0.tar.gz";
        sha256 = "0c6100edd16fefd1557da078c7a31e7b7d7a52ce39fdca2bec29d4f7b6e7600c";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [
        self."cffi"
      ];
      propagatedBuildInputs = [
        self."cffi"
        self."six"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyca/pynacl/";
        license = licenses.asl20;
        description = "Python binding to the Networking and Cryptography (NaCl) library";
      };
    };

    "pyopenssl" = python.mkDerivation {
      name = "pyopenssl-19.0.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/40/d0/8efd61531f338a89b4efa48fcf1972d870d2b67a7aea9dcf70783c8464dc/pyOpenSSL-19.0.0.tar.gz";
        sha256 = "aeca66338f6de19d1aa46ed634c3b9ae519a64b458f8468aec688e7e3c20f200";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."cryptography"
        self."six"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://pyopenssl.org/";
        license = licenses.asl20;
        description = "Python wrapper module around the OpenSSL library";
      };
    };

    "pyparsing" = python.mkDerivation {
      name = "pyparsing-2.3.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/b9/b8/6b32b3e84014148dcd60dd05795e35c2e7f4b72f918616c61fdce83d27fc/pyparsing-2.3.1.tar.gz";
        sha256 = "66c9268862641abcac4a96ba74506e594c884e3f57690a696d21ad8210ed667a";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyparsing/pyparsing/";
        license = licenses.mit;
        description = "Python parsing module";
      };
    };

    "pysocks" = python.mkDerivation {
      name = "pysocks-1.7.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/15/ab/35824cfdee1aac662e3298275fa1e6cbedb52126d1785f8977959b769ccf/PySocks-1.7.0.tar.gz";
        sha256 = "d9031ea45fdfacbe59a99273e9f0448ddb33c1580fe3831c1b09557c5718977c";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Anorov/PySocks";
        license = licenses.bsdOriginal;
        description = "A Python SOCKS client module. See https://github.com/Anorov/PySocks for more information.";
      };
    };

    "pyzmq" = python.mkDerivation {
      name = "pyzmq-18.0.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/f8/48/5416696b9f2eacc7d1f9fe3a7187ad54d769e09585ec0b59c137ab5c7575/pyzmq-18.0.1.tar.gz";
        sha256 = "8b319805f6f7c907b101c864c3ca6cefc9db8ce0791356f180b1b644c7347e4c";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://pyzmq.readthedocs.org";
        license = "LGPL+BSD";
        description = "Python bindings for 0MQ";
      };
    };

    "requests" = python.mkDerivation {
      name = "requests-2.22.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/01/62/ddcf76d1d19885e8579acb1b1df26a852b03472c0e46d2b959a714c90608/requests-2.22.0.tar.gz";
        sha256 = "11e007a8a2aa0323f5a921e9e6a2d7e4e67d9877e85773fba9ba6419025cbeb4";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."certifi"
        self."chardet"
        self."cryptography"
        self."idna"
        self."pyopenssl"
        self."pysocks"
        self."urllib3"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://python-requests.org";
        license = licenses.asl20;
        description = "Python HTTP for Humans.";
      };
    };

    "setuptools-scm" = python.mkDerivation {
      name = "setuptools-scm-3.3.3";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/83/44/53cad68ce686585d12222e6769682c4bdb9686808d2739671f9175e2938b/setuptools_scm-3.3.3.tar.gz";
        sha256 = "bd25e1fb5e4d603dcf490f1fde40fb4c595b357795674c3e5cb7f6217ab39ea5";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pypa/setuptools_scm/";
        license = licenses.mit;
        description = "the blessed package to manage your versions by scm tags";
      };
    };

    "six" = python.mkDerivation {
      name = "six-1.12.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz";
        sha256 = "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/benjaminp/six";
        license = licenses.mit;
        description = "Python 2 and 3 compatibility utilities";
      };
    };

    "urllib3" = python.mkDerivation {
      name = "urllib3-1.24.3";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/8a/3c/1bb7ef6c435dea026f06ed9f3ba16aa93f9f4f5d3857a51a35dfa00882f1/urllib3-1.24.3.tar.gz";
        sha256 = "2393a695cd12afedd0dcb26fe5d50d0cf248e5a66f75dbd89a3d4eb333a61af4";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."certifi"
        self."cryptography"
        self."idna"
        self."pyopenssl"
        self."pysocks"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://urllib3.readthedocs.io/";
        license = licenses.mit;
        description = "HTTP library with thread-safe connection pooling, file post, and more.";
      };
    };

    "virtualenv" = python.mkDerivation {
      name = "virtualenv-16.4.3";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/37/db/89d6b043b22052109da35416abc3c397655e4bd3cff031446ba02b9654fa/virtualenv-16.4.3.tar.gz";
        sha256 = "984d7e607b0a5d1329425dd8845bd971b957424b5ba664729fab51ab8c11bc39";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."six"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://virtualenv.pypa.io/";
        license = licenses.mit;
        description = "Virtual Python Environment builder";
      };
    };

    "websocket-client" = python.mkDerivation {
      name = "websocket-client-0.56.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/c5/01/8c9c7de6c46f88e70b5a3276c791a2be82ae83d8e0d0cc030525ee2866fd/websocket_client-0.56.0.tar.gz";
        sha256 = "1fd5520878b68b84b5748bb30e592b10d0a91529d5383f74f4964e72b297fd3a";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."six"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/websocket-client/websocket-client.git";
        license = licenses.bsdOriginal;
        description = "WebSocket client for Python. hybi13 is supported.";
      };
    };
  };
  localOverridesFile = ./requirements_override.nix;
  localOverrides = import localOverridesFile { inherit pkgs python; };
  commonOverrides = [
    
  ];
  paramOverrides = [
    (overrides { inherit pkgs python; })
  ];
  allOverrides =
    (if (builtins.pathExists localOverridesFile)
     then [localOverrides] else [] ) ++ commonOverrides ++ paramOverrides;

in python.withPackages
   (fix' (pkgs.lib.fold
            extends
            generated
            allOverrides
         )
   )
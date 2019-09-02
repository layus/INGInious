{ pkgs, python }:

self: super: {

  "py" = python.overrideDerivation super."py" (old: {
    buildInputs = old.buildInputs ++ [ self."setuptools-scm" ];
  });

  cffi = super.cffi.override (attrs: {
    propagatedBuildInputs = attrs.propagatedBuildInputs ++ (with self; [
      pkgs.libffi
    ]);
  });

  cryptography = super.cryptography.override (attrs: {
    buildInputs = attrs.buildInputs ++ [ pkgs.openssl ];
    #propagatedBuildInputs = attrs.propagatedBuildInputs ++ (with self; [
    #   # Building with Python 2
    #   enum34
    #   ipaddress
    # ]);
   });



 }

{
  linuxManualConfig,
  ...
}:
let
  src = fetchTarball {
    url = "https://codeberg.org/sdm845/linux/archive/sdm845-next-20260730-1.tar.gz";
    sha256 = "sha256:0nn5z4wc2sfmbfxfndai1z94ba3ldr5xk6pi6x2c2qb879wjmxmb";
  };
  modDirVersion = "7.2.0-rc5-next-20260730";
in
(linuxManualConfig {
  inherit src;
  version = "${modDirVersion}";
  configfile = ./config.aarch64;
  features = {
    efiBootStub = true;
  };
  extraMeta = {
    platforms = [ "aarch64-linux" ];
    hydraPlatforms = [ "" ];
  };
  kernelPatches = [
    {
      name = "synaptics-s3706b-fallback-pdt";
      patch = ./synaptics-s3706b-fallback-pdt.patch;
    }
  ];
}).overrideAttrs
  (old: {
    postUnpack = ''
      cp ${./arch-arm64-boot-dts-sdm845-Makefile} source/arch/arm64/boot/dts/qcom/Makefile
    '';
  })

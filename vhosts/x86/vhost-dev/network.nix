# network.nix
{...}: {
  networking.wireless.enable = true; # Enable wireless networking
  networking.wireless.networks = {
    "cim-dev" = {
      psk = "Unsecure!";
    };
  };
}
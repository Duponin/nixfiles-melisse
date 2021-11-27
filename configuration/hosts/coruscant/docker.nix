{ config, ... }:

{
  virtualisation.docker = {
    enable = true;
    extraOptions = ''
      --ip="127.0.0.1" \
    '';
  };
}

{ config, lib, pkgs, ... }:
let inherit (import ../../lib/hosts.nix { inherit pkgs; }) hosts;
in {
  services.prometheus = {
    enable = true;
    scrapeConfigs = [{
      job_name = "netdata";
      metrics_path = "/api/v1/allmetrics";
      static_configs =
        [{ targets = lib.lists.forEach hosts (host: "${host}.melisse.org"); }];
      params.format = [ "prometheus" ];
      honor_labels = true;
      scheme = "https";
    }];
  };
}

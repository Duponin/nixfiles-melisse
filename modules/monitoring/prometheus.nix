{ config, ... }: {
  services.prometheus = {
    enable = true;
    scrapeConfigs = [{
      job_name = "netdata";
      metrics_path = "/api/v1/allmetrics";
      static_configs = [{
        targets = [
          "aedu.melisse.org"
          "coreilla.melisse.org"
          "coruscant.melisse.org"
          "malastare.melisse.org"
          "rishi.melisse.org"
        ];
      }];
      params.format = [ "prometheus" ];
      honor_labels = true;
      scheme = "https";
    }];
  };
}

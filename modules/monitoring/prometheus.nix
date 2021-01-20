{ config, ... }: {
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "netdata";
        metrics_path = "/api/v1/allmetrics";
        static_configs = [
          {
            targets = [
              "aedu.melisse.org:443"
              "coreilla.melisse.org:443"
              "coruscant.melisse.org:443"
              "malastare.melisse.org:443"
              "rishi.melisse.org:443"
            ];
          }
        ];
        params.format = [ "prometheus" ];
        honor_labels = true;
      }
    ];
  };
}

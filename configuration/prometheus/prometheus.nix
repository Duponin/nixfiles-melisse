{ config, ... }: {
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "node";
        scrape_interval = "15s";
        static_configs = [
          {
            targets = [
              "127.0.0.1:9100"
            ];
            labels = {
              alias = "prometheus.example.com";
            };
          }
        ];
      }
    ];
    alertmanager = {
      enable = true;
      listenAddress = "127.0.0.1";
      configuration = {
        "global" = {
          "smtp_smarthost" = "127.0.0.1:587";
          "smtp_from" = "monitoring@melisse.org";
        };
        "route" = {
          "group_by" = [ "alertname" "alias" ];
          "group_wait" = "30s";
          "group_interval" = "2m";
          "repeat_interval" = "4h";
          "receiver" = "admins";
        };
        "receivers" = [
          {
            "name" = "admins";
            "email_configs" = [
              {
                "to" = "admin@melisse.org";
                "send_resolved" = true;
              }
            ];
          }
        ];
      };
    };
  };
  services.grafana = {
    enable = true;
    addr = "127.0.0.1";
    domain = "localhost";
    rootUrl = "http://localhost";
    provision = {
      enable = true;
      datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9090";
        }
      ];
    };
  };
}

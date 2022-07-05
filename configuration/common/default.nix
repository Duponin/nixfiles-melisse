{ config, pkgs, lib, ... }:
let admin_groups = [ "wheel" ];
in {
  environment.systemPackages = with pkgs; [ git vim ];
  users = {
    mutableUsers = false;
    users = {
      antonin = {
        isNormalUser = true;
        extraGroups = admin_groups;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJh6W2o61dlOIcBXeWRhXWSYD/W8FDVf3/p4FNfL2L6p duponin@rilakkuma"
        ];
      };
      simon = {
        isNormalUser = true;
        extraGroups = admin_groups;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINOiFv7rm8ChxvFaggUHRWcgGriWxkfiIPxhUSgTeA6n ximun@aquilenet.fr"
        ];
      };
      thomas = {
        isNormalUser = true;
        extraGroups = admin_groups;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPq1UGdQQM8uTMkvgdws0bUYXUEaG1gWTte+41MpO4uz didyme@archipad"
        ];
      };
    };
  };
  security.sudo.wheelNeedsPassword = false;
  services = {
    fail2ban = {
      enable = true;
      bantime-increment.enable = true;
    };
    openssh = {
      enable = true;
      challengeResponseAuthentication = false;
      passwordAuthentication = false;
      permitRootLogin = "no";
    };
  };
  nix = {
    trustedUsers = [ "@wheel" ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };

  time.timeZone = "Europe/Paris";
}

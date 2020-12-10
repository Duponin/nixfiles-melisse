{ config, pkgs, lib, ... }: {

  environment.systemPackages = with pkgs; [ git ];
  users.users = {
    antonin = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJh6W2o61dlOIcBXeWRhXWSYD/W8FDVf3/p4FNfL2L6p duponin@rilakkuma"
      ];
    };
    simon = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDjGpWpett2617kQLC3a8lfYQXt834EtTzEDDnq6BrfEKDVUlyeK1F7bNhp1rEtIJeY38xjAsT4KVHCbEAmBAR4wSInf8C4I7af4GLy+T/Omo+iLESDpAqES+os2ZnDK0U6PX5b1UORNGDUr+Pg0aqH4S+PTEbsC4berl4m7DgRMCpKhPfem4nasKl2jasuy/EhlFK8VgM512H+VMSBGk5brtJ6lgtoltGwpwHt1QMiDCQvAXKJbRHn5pN8R1Y1P5KujOlR5AMROoXdvnw1mdpoQy/9dS0+YZPRb2JnGfxd098tF9iT0uFVTslvOYo1Cd3jBNe04RYeRgGvlzQ5V/kK1nSEH505ABOS6clOK62TFGAyklvElpGPEQd25j16fwX2i6MJz9idFf3hHE5DOHI3sxu2fQjRWfkUkgatFpeQfOzmvU6zPBVcUdbGMwE8CNQQHG3MWNpdBspzBgoX5U8m1XJb847Ctm9fXWWZgMrpbJovMAAqpb/GG5EhfvbCzp05WHDbm25RVM7b+PvApQsk7qfCKPwDSNLY1OlBPgbmEAHee6dCoPJftB3yw1+eBJg9+dGdI6Rvt6zdx51HEB4SIkEC1tAFj1BMomJW637f03Kzbmtxy58UTmSYSP+urmsdb5N2Vt1WBB/EclVoldBB+CsfqKnVToseMXMjj+q0Yw== simon@DaoQuan"
      ];
    };
  };
  security.sudo.wheelNeedsPassword = false;
}

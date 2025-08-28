{ pkgs, ... }:
{
  environment.etc."pam.d/hyprlock".text = ''
    auth sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so max_tries=3
    auth sufficient ${pkgs.sssd}/lib/security/pam_sss.so try_first_pass
    auth required ${pkgs.linux-pam}/lib/security/pam_deny.so
  '';
}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the gummiboot efi boot loader.
  boot.loader.grub.device = /dev/sda;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.buildCores = 4;

  time.timeZone = "Europe/London";

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  networking.hostName = "hyland";
  networking.hostId = "48a32733";
  networking.wireless.enable = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_GB.UTF-8";
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [ wget (emacs.override {
    withGTK2 = false; withGTK3 = false;})
  git gnupg haskellPackages.xmobar lsof offlineimap pinentry xlockmore ];

  krb5 = {
    enable = true;
    defaultRealm = "INF.ED.AC.UK";
    kdc = "kdc.inf.ed.ac.uk";
  };

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "ondemand";

  programs.ssh.startAgent = false;
  
  # List services that you want to enable:

  services.locate.enable = true;
  services.locate.interval = "hourly";
  services.locate.localuser = "phil";
  
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    webInterface = false;
    clientConf = ''
      ServerName infcups.inf.ed.ac.uk
    '';
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /backup   localhost(ro,no_root_squash,no_subtree_check)
    '';
    hostName = "localhost";
    createMountPoints = false;
  };

  # Enable the X11 windowing system.
  # nixpkgs.config.allowUnfree = true;
  # services.xserver.videoDrivers = [ "ati_unfree" ];

  services.xserver.enable = true;
  services.xserver.layout = "dvorak";
  services.xserver.synaptics.enable = true;

  # services.xserver.displayManager.lightdm.enable = true;

  services.xserver.displayManager.auto.enable = true;
  services.xserver.displayManager.auto.user = "phil";  

  services.xserver.windowManager.xmonad.enable = true;
  services.xserver.windowManager.xmonad.enableContribAndExtras = true;
  services.xserver.windowManager.xmonad.extraPackages = pkgs:
    [ pkgs.PhilAlsa ];
  services.xserver.windowManager.default = "xmonad";
  services.xserver.desktopManager.default = "none";
  services.xserver.desktopManager.xterm.enable = false;

  services.rsnapshot = {
    enable = true;
    extraConfig = ''
      one_fs	1
      snapshot_root	/backup
      retain		hourly	6
      retain		daily	7
      retain		weekly	4
      retain		monthly	6
      backup		/home/phil/	.		
      backup		/etc/nixos/	nixos/
    '';
    cronIntervals = {
      hourly  = "@ 1h0";
      daily   = "@ 1d30";
      weekly  = "@ 1w8h30";
      monthly = "@ 1m16h30";
    };
  };

  networking.dhcpcd.extraConfig = ''
    static domain_name_servers=209.222.18.222 209.222.18.218
  '';

  services.openvpn.servers = {
    privateinternetaccess = {
      config = ''
        client
        dev tun
        proto tcp
        resolv-retry infinite
        nobind
	remote germany.privateinternetaccess.com 443
        persist-tun
        tls-client
        remote-cert-tls server
        auth-user-pass /root/.vpn/pia.txt
        comp-lzo
        verb 1
        reneg-sec 0
	ca /root/.vpn/ca.crt
        crl-verify /root/.vpn/crl.pem
	route ssh.inf.ed.ac.uk 255.255.255.255 gateway
	route kdc.inf.ed.ac.uk 255.255.255.255 gateway
	route imap.staffmail.ed.ac.uk 255.255.255.255 gateway
	route smtp.staffmail.ed.ac.uk 255.255.255.255 gateway
     '';
    };
#     university = {
#       config = ''
# dev tun
# proto udp
# remote openvpn160.inf.ed.ac.uk
# pull
# rport 5001

# route remote_host 255.255.255.255 net_gateway
# route 129.215.0.0 255.255.0.0
# tls-client
# auth-user-pass /root/.vpn/uni.txt

# comp-lzo

# verb 3
# <ca>
# -----BEGIN CERTIFICATE-----
# MIIFKzCCBBOgAwIBAgICC7gwDQYJKoZIhvcNAQELBQAwgcMxCzAJBgNVBAYTAkdC
# MREwDwYDVQQIEwhTY290bGFuZDESMBAGA1UEBxMJRWRpbmJ1cmdoMSAwHgYDVQQK
# ExdVbml2ZXJzaXR5IG9mIEVkaW5idXJnaDEgMB4GA1UECxMXVW5pdmVyc2l0eSBv
# ZiBFZGluYnVyZ2gxJTAjBgNVBAMTHFVuaXZlcnNpdHkgb2YgRWRpbmJ1cmdoIENB
# IDIxIjAgBgkqhkiG9w0BCQEWE3Bvc3RtYXN0ZXJAZWQuYWMudWswHhcNMTUwNzIy
# MTEwNTA1WhcNMzUwNzE3MTEwNTA1WjCBwzELMAkGA1UEBhMCR0IxETAPBgNVBAgT
# CFNjb3RsYW5kMRIwEAYDVQQHEwlFZGluYnVyZ2gxIDAeBgNVBAoTF1VuaXZlcnNp
# dHkgb2YgRWRpbmJ1cmdoMSAwHgYDVQQLExdVbml2ZXJzaXR5IG9mIEVkaW5idXJn
# aDElMCMGA1UEAxMcVW5pdmVyc2l0eSBvZiBFZGluYnVyZ2ggQ0EgMjEiMCAGCSqG
# SIb3DQEJARYTcG9zdG1hc3RlckBlZC5hYy51azCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBALxRq31+yYJEbvpfN/vFa+/fBEDqw1r5Rzo2RNikc0tcBXkC
# poy2RlCw9u7qi2ManDrqLujwqvmcLyyExtp22pYD0+7mqZLbx3AU/GU2VxZg1vEZ
# RZkFF/WQoVTnturpzmjjuRhFlsK8Y0jvRKgJGU1noCHX5t5d7AzzraYWUd8YsY2T
# zfGitDAMDWAcyWI7A5CqstcJZIrPUWbK3yxs9TfrszTG2mrBGl0w9TV8PS+pVFsM
# 6yBN8VhLVD85qqLilfJzLWYlJhM2YNw5/DCu5oY/NLSTtbV+vQcX3TAjg0R31bDm
# 6PBDdoo+FLxfhMHCARZyBM9b2sorrZCJU1kUQSECAwEAAaOCASUwggEhMB0GA1Ud
# DgQWBBShyitGMHnx5EnmpGVyBOPjc0WFBzCB8QYDVR0jBIHpMIHmgBShyitGMHnx
# 5EnmpGVyBOPjc0WFB6GByaSBxjCBwzELMAkGA1UEBhMCR0IxETAPBgNVBAgTCFNj
# b3RsYW5kMRIwEAYDVQQHEwlFZGluYnVyZ2gxIDAeBgNVBAoTF1VuaXZlcnNpdHkg
# b2YgRWRpbmJ1cmdoMSAwHgYDVQQLExdVbml2ZXJzaXR5IG9mIEVkaW5idXJnaDEl
# MCMGA1UEAxMcVW5pdmVyc2l0eSBvZiBFZGluYnVyZ2ggQ0EgMjEiMCAGCSqGSIb3
# DQEJARYTcG9zdG1hc3RlckBlZC5hYy51a4ICC7gwDAYDVR0TBAUwAwEB/zANBgkq
# hkiG9w0BAQsFAAOCAQEADnXxO0c4Y3Vdl8RhCKxAoX8OxoY59u+UZU7SnMoHSRfA
# lEcBUZU8ttiAJZdPl0A0DxvLYA14sfVPiDuC20+0YTGR+t3Tig3An43nMzPr/qst
# KSSazFeo1n47o/00hYyBPAOSVJh2sDvxN2LB4e/D6V/QQNUf5YOkXN838Sot5YcM
# SMfCKPAyeqdJYu/VOLdTaWOVhCzkRaX/1V1taknIZx17HB6Lwci7x6Pdxa3WqEJV
# MYeqz2e2olAP5lJSNSmmQneCIkZz7hUtzKQhfZJRLDOR5J4KojbDfBYsNiORphjp
# dcCFLjnfA+oyjXZP44zmVM1NXo0mGPWisfembj7lMg==
# -----END CERTIFICATE-----
# </ca>
# <tls-auth>
# -----BEGIN OpenVPN Static key V1-----
# a188b2d2654b2ebbcbf307cc30c83e15
# c737320d4b4b6b4f0960b1f06ea6e50f
# 75ee356a4ac906d1804414cf2498bf1c
# b7ebe58a5d3fef0b988508dbe3363800
# 1f835576ee8796ddc0303e65a5cf8928
# e3d933eb6afde2b0bb6d4ba6daf9ca56
# 42a7ffed4d578f333ad95463596a08ff
# 34a9eb8f8ef1fcbad1681942d4312a60
# 6d17baa0b1d3c723f1acf59bc05026c2
# 619d84142815adec30a5a85de5c19243
# 612bf39fbe20da1e6d4c6ef28ac679e1
# 489dcc153a69b98a3ea1418691916510
# e4dcd138599484c5555db514909adbd9
# a7a31682a4045b9185b32b2dfc1d8161
# 6992a620636c8a3214b895228e1f5e0a
# e5cff20436bf49071050c7c594b8e04d
# -----END OpenVPN Static key V1-----
# </tls-auth>
#       '';
#     };
  };
# remote germany.privateinternetaccess.com 443
# remote uk-london.privateinternetaccess.com 443
# remote us-newyorkcity.privateinternetaccess.com 443
  
  services.cron.enable = false;
  services.fcron.enable = true;

  # services.openafsClient = {
  #   enable = true;
  #   cellName = "inf.ed.ac.uk";
  #   cacheSize = "500000";
  #   sparse = true;
  # };
 
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.phil = {
    home = "/home/phil";
    extraGroups = [ "networkmanager" ];
    isNormalUser = true;
    uid = 1000;
  };
  users.extraUsers.ipfs = {
    home = "/home/ipfs";
    isNormalUser = true;
    uid = 1001;
  };

  system.autoUpgrade.enable = true;

  # systemd.user.services.sshtunnel = {
  #   description = "Forward SSH through Edinburgh Uni tunnel";
  #   serviceConfig = {
  #     ExecStart = "${pkgs.kerberos}/bin/kinit pscott7 -k -t /root/pscott7.keytab && -L 33014:localhost:33014 pscott7@ssh.inf.ed.ac.uk";
  #     Restart = "no";
  #   };
  #   after = [ "network-interfaces.target" ];
  # };

  # systemd.services.sshtunnel.enable = true;

  # systemd.user.services.offlineimap = {
  #   description = "Offline IMAP";
  #   serviceConfig = {
  #     ExecStart = "${pkgs.offlineimap}/bin/offlineimap}";
  #     Restart = "onfail";
  #   };
  # }

  # systemd.services.offlineimap.enable = true;

  nixpkgs.config =
    {
      haskellPackageOverrides = self: super:
      {
        "PhilAlsa" = self.mkDerivation {
          pname = "PhiledAlsa";
          version = "0.1";
          src = pkgs.fetchFromGitHub {
            owner = "Chattered";
            repo = "PhiledAlsa";
            rev = "master";
            sha256 = "05nki9xqwl9cpdwnv8waz4ccjky89ldmvgxyfx0wji6mqinibl7h";
          };
          isLibrary = true;
          isExecutable = false;
          buildDepends = (with super; [ mtl ]);
          extraLibraries = [ pkgs.alsaLib ];
          jailbreak = true;
          description = "A simple interface to ALSA's API";
          license = pkgs.stdenv.lib.licenses.mit;
          hydraPlatforms = pkgs.stdenv.lib.platforms.none;
        };
      };
      packageOverrides = super:
      {
        openssh = super.openssh.override { withKerberos = true; };
      };
  };
}

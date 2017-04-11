{ config, pkgs, ... }:

let
  utils = import ./utils.nix;
  rsnapshotService = start: interval: {
    systemd.services."rsnapshot${interval}" = {
      description = "rsnapshot ${interval} backup";
      serviceConfig = {
        ExecStart = "${config.system.path}/bin/rsnapshot ${interval}";
        Restart = "no";
      };
      after = [ "default.target" ];
      wantedBy = [ "default.target" ];
      enable = true;
    };
    systemd.timers."rsnapshot${interval}" = {
      description = "rsnapshot ${interval} timer";
      timerConfig = {
        OnBootSec="${start}";
        OnActiveUnitSec="${interval}";
        Unit = "rsnapshot${interval}.service";
        Persistent = "true";
      };
      wantedBy = [ "timers.target" ];
      enable = true;
    };
  };
in
utils.addDeep (rsnapshotService "1h0" "hourly")
(utils.addDeep (rsnapshotService "2h0" "daily")
 (utils.addDeep (rsnapshotService "3h0" "weekly")
  (utils.addDeep (rsnapshotService "4h0" "monthly")
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.initrd.postMountCommands =
    "cryptsetup luksOpen --key-file /mnt-root/root/swapkeyfile /dev/disk/by-id/wwn-0x5000cca768cffc54-part3 swap";
  swapDevices = [ { device = "/dev/mapper/swap"; } ];

  boot.loader.grub.device = /dev/disk/by-label/NIXOSBOOT;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.buildCores = 4;

  time.timeZone = "Europe/London";

  hardware.pulseaudio.enable = true;

  networking.hostName = "hyland";
  networking.hostId = "48a32733";
  networking.wireless.enable = true;
  networking.firewall.trustedInterfaces = [ "tun0" ];

  networking.dhcpcd.extraConfig = ''
    static domain_name_servers=209.222.18.222 209.222.18.218
 '';

  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_GB.UTF-8";
  };

  environment.systemPackages = with pkgs; [ wget (emacs.override {
    withGTK2 = false; withGTK3 = false;})
  aspell aspellDicts.en git gnupg haskellPackages.xmobar lsof offlineimap pinentry
  xlockmore xclip ];

  krb5 = {
    enable = true;
    defaultRealm = "INF.ED.AC.UK";
    kdc = "kdc.inf.ed.ac.uk";
  };

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "ondemand";

  # Using GPG_AGENT
  programs.ssh.startAgent = false;

  services.locate.enable = true;
  services.locate.interval = "hourly";
  services.locate.localuser = "phil";

  services.nfs.server = {
    enable = true;
    exports = ''
      /backup   localhost(ro,no_root_squash,no_subtree_check)
    '';
    hostName = "localhost";
    createMountPoints = false;
  };

  systemd.mounts = [
    {
      where = "/home/phil/yesterday";
      what = "localhost:/backup/daily.0/home/phil/";
      type = "nfs";
    }
    {
      where = "/home/phil/recent";
      what = "localhost:/backup/hourly.0/home/phil/";
      type = "nfs";
    }
  ];

  systemd.automounts = [
    {
      where = "/home/phil/yesterday";
      wantedBy = [ "multi-user.target" ];
    }
    {
      where = "/home/phil/recent";
      wantedBy = [ "multi-user.target" ];
    }
  ];

  services.xserver = {
    enable = true;
    layout = "dvorak";
    displayManager.auto.enable = true;
    displayManager.auto.user = "phil";
    windowManager.default = "xmonad";
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
    # Needed for my .xmonad/xmonad.hs
    windowManager.xmonad.extraPackages = pkgs: [ pkgs.PhilAlsa ];
    desktopManager.default = "none";
    desktopManager.xterm.enable = false;
    synaptics.enable = true;
  };

  # Tabs are REQUIRED here
  services.rsnapshot = {
    enable = true;
    extraConfig = ''
      one_fs	1
      snapshot_root	/backup
      retain	hourly	6
      retain	daily	7
      retain	weekly	4
      retain	monthly	6
      backup	/home/phil/	.
      backup	/etc/nixos/	nixos/
    '';
  };

  services.openvpn.servers = {
    privateinternetaccess = {
      config = ''
        client
        dev tun
        proto tcp
        resolv-retry infinite
        nobind
        remote nl.privateinternetaccess.com 443
        persist-tun
        tls-client
        remote-cert-tls server
        auth-user-pass /root/.vpn/pia.txt
        comp-lzo
        verb 1
        reneg-sec 0
        ca /root/.vpn/ca.crt
        crl-verify /root/.vpn/crl.pem
        route momentoftop.com 255.255.255.255 gateway
     '';
    };
    # Alternative servers
    # remote germany.privateinternetaccess.com 443
    # remote uk-london.privateinternetaccess.com 443
    # remote us-newyorkcity.privateinternetaccess.com 443
    # remote nl.privateinternetaccess.com 443
  };

  users.extraUsers.phil = {
    home = "/home/phil";
    isNormalUser = true;
    extraGroups = [ "video" ];
    uid = 1000;
  };
  users.extraUsers.ipfs = {
    home = "/home/ipfs";
    isNormalUser = true;
    uid = 1001;
  };
  users.extraUsers.alyn = {
    home = "/home/alyn";
    isNormalUser = true;
    uid = 1002;
  };

  system.autoUpgrade.enable = true;

  # User services

  systemd.user.services.offlineimap = {
    description = "Offline IMAP";
    serviceConfig = {
      Environment="GNUPGHOME=/tails/gnupg";
      ExecStartPre = "${config.system.path}/bin/gpg-connect-agent /bye";
      ExecStart = "${pkgs.offlineimap}/bin/offlineimap";
      Restart = "on-failure";
    };
    after = [ "network-interfaces.target" ];
    wantedBy = [ "default.target" ];
    enable = true;
  };

  nixpkgs.config =
    {
      # Needed by xmonad.extraPackages
      haskellPackageOverrides = self: super:
      {
        "PhilAlsa" = self.mkDerivation {
          pname = "PhiledAlsa";
          version = "0.1";
          src = pkgs.fetchFromGitHub {
            owner = "Chattered";
            repo = "PhiledAlsa";
            rev = "master";
            sha256 = "0f1kvqid2vp22v10n2jl18c5qrrl2wza1rc11avs6gnvkwzmw07x";
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
  };
})))

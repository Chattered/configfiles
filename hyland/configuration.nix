{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.grub.device = /dev/sda;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.buildCores = 4;

  time.timeZone = "Europe/London";

  # For running steam
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  networking.hostName = "hyland";
  networking.hostId = "48a32733";
  networking.wireless.enable = true;
  networking.firewall.extraCommands = ''
iptables -I INPUT -i tun0 -j ACCEPT
'';

  networking.dhcpcd.extraConfig = ''
    static domain_name_servers=209.222.18.222 209.222.18.218
  '';

  # If using a de using network manager.
  # networking.networkmanager.insertNameservers = [
  #   "209.222.18.222"
  #   "209.222.18.218"
  # ];

  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_GB.UTF-8";
  };

  environment.systemPackages = with pkgs; [ wget (emacs.override {
    withGTK2 = false; withGTK3 = false;})
  aspell aspellDicts.en autossh git gnupg haskellPackages.xmobar lsof offlineimap pinentry
  xlockmore ];

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

  # Commented out, since the free drivers seem just as performant, and have KMS
  # support. The proprietary drivers don't like the auto dm, but lightdm works.
  # nixpkgs.config.allowUnfree = true;
  # services.xserver.videoDrivers = [ "ati_unfree" ];
  # services.xserver.displayManager.lightdm.enable = true;

  services.xserver = {
    enable = true;
    layout = "dvorak";
    synaptics.enable = true;
    displayManager.auto.enable = true;
    displayManager.auto.user = "phil";
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
    # Needed for my .xmonad/xmonad.hs
    windowManager.xmonad.extraPackages = pkgs: [ pkgs.PhilAlsa ];
    windowManager.default = "xmonad";
    desktopManager.default = "none";
    desktopManager.xterm.enable = false;
  };

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
    cronIntervals = {
      hourly  = "@ 1h0";
      daily   = "@ 1d30";
      weekly  = "@ 1w8h30";
      monthly = "@ 1m16h30";
    };
  };

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
        route irc.freenode.net 255.255.255.255 gateway
     '';
    };
    # Alternative servers
    # remote germany.privateinternetaccess.com 443
    # remote uk-london.privateinternetaccess.com 443
    # remote us-newyorkcity.privateinternetaccess.com 443
  };

  services.cron.enable = false;
  services.fcron.enable = true;

  # Broken upstream for now
  # services.openafsClient = {
  #   enable = true;
  #   cellName = "inf.ed.ac.uk";
  #   cacheSize = "500000";
  #   sparse = true;
  # };

  users.extraUsers.phil = {
    home = "/home/phil";
    isNormalUser = true;
    uid = 1000;
  };
  users.extraUsers.ipfs = {
    home = "/home/ipfs";
    isNormalUser = true;
    uid = 1001;
  };

  system.autoUpgrade.enable = true;

  # User services
  systemd.user.services.sshtunnel = {
    description = "Forward SSH through Edinburgh Uni tunnel";
    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.autossh}/bin/autossh -M 30000 -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes -f -L 33014:localhost:33014 pscott7@ssh.inf.ed.ac.uk -N";
      Restart = "on-failure";
    };
    after = [ "network-interfaces.target" ];
    wantedBy = [ "default.target" ];
    enable = true;
  };

  systemd.user.services.offlineimap = {
    description = "Offline IMAP";
    serviceConfig = {
      ExecStartPre = "${config.system.path}/bin/gpg-connect-agent /bye";
      ExecStart = "${pkgs.offlineimap}/bin/offlineimap";
      Restart = "on-failure";
    };
    after = [ "network-interfaces.target" ];
    wantedBy = [ "default.target" ];
    enable = true;
  };

  systemd.user.services.kerberosrefresh = {
    description = "Kerberos ticket refresher";
    serviceConfig = {
      ExecStart = "${config.system.path}/bin/kinit pscott7 -k -t /home/phil/pscott7.keytab}";
      Restart = "always";
    };
    enable = true;
  };

  systemd.user.timers.kerberosrefresh = {
    description = "Kerberos ticket refresher timer";
    timerConfig = {
      OnCalendar="daily";
      Unit = "kerberosrefresh.service";
      Persistent = "true";
    };
    after = [ "network-interfaces.target" ];
    wantedBy = [ "timers.target" ];
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

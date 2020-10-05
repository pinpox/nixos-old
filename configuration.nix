# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ];

  # Use GRUB2 as EFI boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Encrypted drive to be mounted by the bootloader. Path of the device will
  # have to be changed for each install.
  boot.initrd.luks.devices = {
    root = {
      # Get UUID from blkid /dev/sda2
      device = "/dev/disk/by-uuid/f4aaaf6d-4eb3-4a2d-a35e-f8e780ac0110";
      preLVM = true;
      allowDiscards = true;
    };
  };

  # /tmp is cleaned after each reboot
  boot.cleanTmpDir = true;

  # Users allowed to run nix
  nix.allowedUsers = ["root" "pinpox"];

  networking  = {

    # Define the hostname
    hostName = "baobab";

    # Enables wireless support via wpa_supplicant.
    # networking.wireless.enable = true;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.enp0s3.useDHCP = true;

    # Enable networkmanager
    networkmanager.enable = true;

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Additional hosts to put in /etc/hosts
    extraHosts =
      ''
        192.168.2.84 backup-server
      '';
  };

  # Set localization properties and timezone
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "colemak";
  };

  time.timeZone = "Europe/Berlin";

  # System-wide environment variables to be set
  environment.variables = {
    EDITOR = "nvim";
    GOPATH = "~/.go";
    VISUAL = "nvim";
    # Use librsvg's gdk-pixbuf loader cache file as it enables gdk-pixbuf to load
    # SVG files (important for icons)
    GDK_PIXBUF_MODULE_FILE = "$(echo ${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/*/loaders.cache)";
  };

  # Needed for zsh completion of system packages, e.g. systemd
  environment.pathsToLink = [ "/share/zsh" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    python
    ctags
    ruby
    python
    borgbackup
    go
    ripgrep
    nodejs
    killall
    arandr
    wget
    neovim
    git
    zsh
    gnumake
  ];

  programs.dconf.enable = true;

  programs.chromium = {
    enable = true;
    extraOpts = {
      "BrowserSignin" = 0;
      "SyncDisabled" = true;
      "PasswordManagerEnabled" = false;
      "SpellcheckEnabled" = true;
      "SpellcheckLanguage" = [ "de" "en-US" ];
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "gnome3";
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      vim = "nvim";
    };
    enableCompletion = true;
    autosuggestions.enable = true;
  };

  # Virtualbox stuff
  virtualisation.virtualbox.guest.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };

    # Enable Wireguard
    networking.wireguard.interfaces = {

      wg0 = {

        # Determines the IP address and subnet of the client's end of the
        # tunnel interface.
        ips = [ "192.168.7.10/24" ];

        # Path to the private key file
        privateKeyFile = "/secrets/wireguard/privatekey";
        peers = [
          {
            # Public key of the server (not a file path).
            publicKey = "XKqEk5Hsp3SRVPrhWD2eLFTVEYb9NYRky6AermPG8hU=";

            # Don't forward all the traffic via VPN, only particular subnets
            allowedIPs = [ "192.168.7.0/24" ];

            # Server IP and port.
            endpoint = "vpn.pablo.tools:51820";

            # Send keepalives every 25 seconds. Important to keep NAT tables
            # alive.
            persistentKeepalive = 25;
          }
        ];
      };
    };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    autorun = true;
    layout = "us";
    dpi = 125;
    xkbVariant = "colemak";
    xkbOptions = "caps:escape";

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      startx.enable = true;
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
  };

  # Backup with borgbackup to remote server. The connection key and repository
  # encryption passphrase is read from /secrets. This directory has to be
  # copied ther *manually* (so this config can be shared publicly)!
  services.borgbackup.jobs.home = {

    # Paths to backup, home should be enough for now, since system-wide
    # configuration is generated by nixOS
    paths = "/home";




    # Remote servers repository to use. Archives will be labeled with the
    # hostname and a timestamp
    repo = "ssh://borg@backup-server//mnt/backup/borgbackup/${config.networking.hostName}";

    # Don't create repo if it does not exist. Ensures the backup fails, if for
    # some reason the backup drive is not mounted or the path has changed.
    doInit = false;

    # Encryption and connection keys are read from /secrets
    encryption = {
      mode = "repokey";
      passCommand = "cat /secrets/borg/repo-passphrase";
    };
    environment.BORG_RSH = "ssh -i /secrets/ssh/backup-key";

    # Print more infomation to log and set intervals at which resumable
    # checkpoints are created
    extraCreateArgs = "--verbose --list --checkpoint-interval 600";

    # Exclude some directories from backup that contain garbage
    exclude = [
      "*.pyc"
      "*/cache2"
      "/*/.cache"
      "/*/.config/Signal"
      "/*/.config/chromium"
      "/*/.config/discord"
      "/*/.container-diff"
      "/*/.gvfs/"
      "/*/.local/share/Trash"
      "/*/.mozilla/firefox/*.default/Cache"
      "/*/.mozilla/firefox/*.default/OfflineCache"
      "/*/.npm/_cacache"
      "/*/.thumbnails"
      "/*/.ts3client"
      "/*/.vagrant.d"
      "/*/.vim"
      "/*/Cache"
      "/*/Downloads"
      "/*/VirtualBox VMs"
      "discord/Cache"
    ];

    compression = "lz4";

    # Backup will run daily
    startAt = "daily";
  };

  # Install some fonts system-wide, especially "Source Code Pro" in the
  # Nerd-Fonts pached version with extra glyphs.
  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "SourceCodePro" ]; })
      noto-fonts-emoji
      corefonts
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {

    # Shell is set to zsh for all users as default.
    defaultUserShell = pkgs.zsh;

    users.pinpox = {
      isNormalUser = true;
      home = "/home/pinpox";
      description = "Pablo Ovelleiro Corral";
      extraGroups = [ "wheel" "networkmanager" "audio"];
      shell = pkgs.zsh;

      # Public ssh-keys that are authorized for the user. Fetched from homepage
      # and github profile.
      openssh.authorizedKeys.keyFiles = [
        ( builtins.fetchurl { url = "https://pablo.tools/ssh-key"; })
        ( builtins.fetchurl { url = "https://github.com/pinpox.keys"; })
      ];
    };
  };

  # Clean up old generations after 30 days
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}

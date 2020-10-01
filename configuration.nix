# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    #./home-manager/nixos
  ];

# Use the systemd-boot EFI boot loader.
boot.loader.grub.enable = true;
boot.loader.grub.version = 2;
boot.loader.grub.device = "nodev";
boot.loader.grub.efiSupport = true;
boot.loader.efi.canTouchEfiVariables = true;
boot.cleanTmpDir = true;

nix.allowedUsers = ["root" "pinpox"];

boot.initrd.luks.devices = {
  root = {
    # Get UUID from blkid /dev/sda2
    device = "/dev/disk/by-uuid/f4aaaf6d-4eb3-4a2d-a35e-f8e780ac0110";
    preLVM = true;
    allowDiscards = true;
  };
};

networking.hostName = "baobab"; # Define your hostname.
# networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

# The global useDHCP flag is deprecated, therefore explicitly set to false here.
# Per-interface useDHCP will be mandatory in the future, so this generated config
# replicates the default behaviour.
networking.useDHCP = false;
networking.interfaces.enp0s3.useDHCP = true;
networking.networkmanager.enable = true;

# Configure network proxy if necessary
# networking.proxy.default = "http://user:password@proxy:port/";
# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

# Select internationalisation properties.
i18n.defaultLocale = "en_US.UTF-8";
console = {
  font = "Lat2-Terminus16";
  keyMap = "colemak";
};

# Set your time zone.
time.timeZone = "Europe/Berlin";

environment.variables = {
  EDITOR = "nvim";
  GOPATH = "~/.go";
  VISUAL = "nvim";
};

# Needed for zsh completion of system packages, e.g. systemd

environment.pathsToLink = [ "/share/zsh" ];



# List packages installed in system profile. To search, run:
# $ nix search wget
environment.systemPackages = with pkgs; [
  python
  ruby
  go
  ripgrep
  nodejs
  killall
  arandr
  lxappearance
  nitrogen
  wget
  neovim
  i3-gaps
  ansible
  git
  source-code-pro
  networkmanagerapplet
  termite
  zsh
  antibody
  gnumake
  ctags
  dconf
  pavucontrol
];

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
nixpkgs.config.allowUnfree = true;
virtualisation.virtualbox.guest.enable = true;

# List services that you want to enable:
# Enable the OpenSSH daemon.
services.openssh = {
  enable = true;
  passwordAuthentication = false;
  challengeResponseAuthentication = false;
};

  # Enable Wireguard
  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ "192.168.7.10/24" ];

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/etc/wireguard/privatekey";

      peers = [
        # For a client configuration, one peer entry for the server will suffice.
        {
          # Public key of the server (not a file path).
          publicKey = "XKqEk5Hsp3SRVPrhWD2eLFTVEYb9NYRky6AermPG8hU=";

          # Forward all the traffic via VPN.
          allowedIPs = [ "192.168.7.0/24" ];
          # Or forward only particular subnets
          #allowedIPs = [ "10.100.0.1" "91.108.12.0/22" ];

          # Set this to the server IP and port.
          endpoint = "vpn.pablo.tools:51820";

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
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
  xkbVariant = "colemak";
  xkbOptions = "caps:escape";

  desktopManager = {
    xterm.enable = false;
  };

  displayManager = {
    defaultSession = "i3";
    startx.enable = true;
  };

  windowManager.i3 = {
    package = pkgs.i3-gaps;
    enable = true;
    extraPackages = with pkgs; [
      rofi
      polybar
      i3lock-fancy
      playerctl
      picom
    ];

  };
};

# Install fonts
fonts = {
  enableFontDir = true;
  fonts = with pkgs; [
    source-code-pro
    font-awesome
    font-awesome_4
    noto-fonts
    noto-fonts-emoji
    corefonts
    unifont
  ];
};

# Define a user account. Don't forget to set a password with ‘passwd’.
users = {
  defaultUserShell = pkgs.zsh;
    users.pinpox = {
      isNormalUser = true;
      home = "/home/pinpox";
      description = "Pablo Ovelleiro Corral";
      extraGroups = [ "wheel" "networkmanager" "audio"];
      shell = pkgs.zsh;

      openssh.authorizedKeys.keyFiles = [
        ( builtins.fetchurl { url = "https://pablo.tools/ssh-key"; })
        ( builtins.fetchurl { url = "https://github.com/pinpox.keys"; })
      ];
     };
   };

# This value determines the NixOS release from which the default
# settings for stateful data, like file locations and database versions
# on your system were taken. It‘s perfectly fine and recommended to leave
# this value at the release version of the first install of this system.
# Before changing this value read the documentation for this option
# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
system.stateVersion = "20.03"; # Did you read the comment?

}



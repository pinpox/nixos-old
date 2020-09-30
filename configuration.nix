# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

# let
#   home-manager = builtins.fetchGit {
#     url = "https://github.com/rycee/home-manager.git";
#     rev = "abfb4cde51856dbee909f373b59cd941f51c2170" ;
#     ref = "release-20.03";
#   };
# in
{
  imports =
    [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./home-manager/nixos
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
  chromium
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

programs.chromium = {
  enable = true;
  extensions = [
    "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
    "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
    "gcbommkclmclpchllfjekcdonpmejbdp" # HTTPS Everywhere
    "lbhnkgjaoonakhladmcjkemebepeohkn" # Vim Tips New Tab
  ];

  extraOpts = {
    "BrowserSignin" = 0;
    "SyncDisabled" = true;
    "PasswordManagerEnabled" = false;
    "SpellcheckEnabled" = true;
    "SpellcheckLanguage" = [
      "de"
      "en-US"
    ];
  };
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

    configFile = ./configs/i3/config;
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
    extraUsers.pinpox = {
      isNormalUser = true;
      home = "/home/pinpox";
      description = "Pablo2";
      extraGroups = [ "wheel" "networkmanager" "audio"];
      shell = pkgs.zsh;

      openssh.authorizedKeys.keyFiles = [
        (
          builtins.fetchurl {
            url    = "https://pablo.tools/ssh-key";
          }
          )
          ( builtins.fetchurl {
            url    = "https://github.com/pinpox.keys";
          }
          )
        ];

        packages = with pkgs; [
          thunderbird
        ];
      };
    };

    home-manager.users.pinpox= {
    # Email
    accounts.email.accounts = {
    pablo_tools = {
      address = "mail@pablo.tools";
      primary = true;
      # gpg = {
      #   # key = "";
      #   signByDefault = true;
      # };
      # imap.host = "posteo.de";
      # mbsync = {
      #   enable = true;
      #   create = "maildir";
      # };
      # msmtp.enable = true;
      # notmuch.enable = true;
      # primary = true;
      # realName = "Ben Justus Bals";
      # signature = {
      #   text = ''
      #     mfg pablo
      #   '';
      #   showSignature = "append";
      # };
      # passwordCommand = "mail-password";
      # smtp = {
      #   host = "";
      # };
      # userName = "";
    };
  };


    # accounts.email.accounts.<name>.gpg

    # Fontconfig
    # fonts.fontconfig.enable

    # GTK settings
    gtk = {
      enable = true;
      font = {
        # package = "Source Code Pro Semibold";
        name = "Source Code Pro Semibold";
      };
      gtk2 = {
        extraConfig = "gtk-can-change-accels = 1";
      };

      gtk3 = {
        extraConfig =  { gtk-cursor-blink = false; gtk-recent-files-limit = 20; };
        bookmarks = [ "file:///home/pinpox/Documents" ];
      };

      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus";
      };



    };

      # General stuff TODO
      # home.activation...
      # home.packages...
      # home.file...
      # home.keyboard...
      # home.language...
      # home.sessionVariables...
      manual.manpages.enable = true;


      # Autorandr
      # TODO

      # Bat
      programs.bat = {
        enable  = true;
        config = {
          # TODO look up opionts
          theme = "TwoDark";
        };
        # themes = { TODO };
      };

      # Broot TODO
      # programs.broot =

      # Browserpass
      programs.browserpass = {
        enable = true;
        browsers = [ "chromium" "firefox" ];
      };

      programs.chromium = {
        enable = true;
        # extensions = [ TODO ]
      };


      programs.firefox = {
        enable = true;
        # profiles = TODO
        # extensions = [ TODO ]
      };

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
        # TODO more options
      };

      programs.dircolors = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.git = {
        enable = true;
        # ignores TODO
        # extraConfig TODO
        signing = {
          key = "TODO";
          signByDefault = true;
        };

        userEmail = "git@pablo.tools";
        userName = "Pablo Ovelleiro Corral";
      };

      # programs.go = {TODO}
      # programs.gpg = {TODO}
      programs.htop = {
        enable = true;
        # enableMouse = true;
        # showCpuFrequency = true;
        treeView = true;
      };

      programs.jq = {
        enable = true;
      };

      programs.keychain = {
        enable = true;
        enableZshIntegration = true;
        enableXsessionIntegration = true;
      };


      # programs.mcfly.

    # programs.mvp
    programs.neomutt = {
      enable =  true;
      # TODO
    };


    programs.neovim = {
      enable = true;
      # TODO
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      withPython = true;
      withPython3 = true;
      withRuby = true;
    };

    programs.password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
      # settings = TODO
    };

    # TODO maybe replace with zoxide
    programs.pazi = {
      enable = true;
      enableZshIntegration = true;
    };

    # TODO
    # poweline-go
    # readline


    programs.rofi = {
      enable = true;
      # TODO
      # colors =
      # br
    };

    # TODO ssh client config

    # TODO look at starship theme for zsh
    # programs.starship = {
    #   enable = true;
    #   enableZshIntegration = true;
    # };

    programs.tmux = {
      enable = true;
      clock24 = true;
      # TODO other optoins

    };

    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      autocd = true;
      dotDir = ".config/zsh";
      # history =
      # initExtra =
      # TODO extra options
      # plugins
    };







    # Alacritty
    programs.alacritty = {
      enable = true;
      settings = {
        env.TERM = "xterm-256color";
        window = {
          dimensions = {
            lines = 3;
            columns = 200;
          };

          padding = {
            lines = 3;
            columns = 200;
          };
        };

        scrolling.history = 10000;
        font = {
          normal = {
            family =  "Office Code Pro";
          };
          bold= {
            family =  "Office Code Pro";
            style =  "bold";
          };

          italic= {
            family =  "Office Code Pro";
            style  = "italic";
          };
          size =  10;
        };

        key_bindings = [
          {
            key = "K";
            mods = "Control";
            chars = "\\x0c";
          }
        ];
      };
    };




    services.blueman-applet.enable = true;

      # TODO checkout
    # services.cbatticon = {
      # enable = true;
    # };

    services.dunst = {
      enable = true;
      # iconTheme
      # settings = {}
    };

    services.gnome-keyring = {
      enable = true;
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };

    #TODO check out
    # services.grobi

    services.network-manager-applet.enable = true;

    # Pulseaudio tray
    services.pasystray.enable = true;

    # Picom X11 compositor
    services.picom = {
      enable = true;
      # activeOpacity = TODO
      # backend = TODO
      # TODO: other options
    };

    # TODO configure polybar
    # services.polybar.enable = true


    # servieces.random-background = {} TODO
    # services.spotifyd = {} TODO
    # services.syncthing = {} TODO
    # services.udiskie= {} TODO

    services.xscreensaver = {
      enable = true;
      # settings = TODO
    };

    # services.xsuspender


    # TODO xdg management
    # xdg. ...


    # TODO xsession management
    #
    #xdg.configHome = ~/.config;
    xdg.configFile."i3/config".source = ./configs/i3/config;
  };




# This value determines the NixOS release from which the default
# settings for stateful data, like file locations and database versions
# on your system were taken. It‘s perfectly fine and recommended to leave
# this value at the release version of the first install of this system.
# Before changing this value read the documentation for this option
# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
system.stateVersion = "20.03"; # Did you read the comment?

}



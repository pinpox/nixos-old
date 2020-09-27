# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
	imports =
		[ # Include the results of the hardware scan.
		./hardware-configuration.nix
		];

# Use the systemd-boot EFI boot loader.
#boot.loader.systemd-boot.enable = true;
#boot.loader.efi.canTouchEfiVariables = true;
	boot.loader.grub.enable = true;
	boot.loader.grub.version = 2;
	boot.loader.grub.device = "nodev";
	boot.loader.grub.efiSupport = true;
	boot.loader.efi.canTouchEfiVariables = true;

	boot.initrd.luks.devices = {
		root = {
			device = "/dev/disk/by-uuid/f4aaaf6d-4eb3-4a2d-a35e-f8e780ac0110";
			preLVM = true;
			allowDiscards = true;
		};
	};

# Do
#   boot.initrd.luks.devices =
#     { root = {...}; }
# instead of
#   boot.initrd.luks.devices =
#     [ { name = "root"; ...} ]
#


	networking.hostName = "nixos"; # Define your hostname.
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

# List packages installed in system profile. To search, run:
# $ nix search wget
	environment.systemPackages = with pkgs; [
		python
			ruby
			go
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
            gnumake
            ctags
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


# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
# networking.firewall.enable = false;

# Enable CUPS to print documents.
# services.printing.enable = true;

# Enable sound.
	sound.enable = true;
	hardware.pulseaudio.enable = true;

# Enable the X11 windowing system.
# services.xserver.enable = true;
# services.xserver.layout = "us";
# services.xserver.xkbOptions = "eurosign:e";
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




# Enable touchpad support.
# services.xserver.libinput.enable = true;

# Enable the KDE Desktop Environment.
# services.xserver.displayManager.sddm.enable = true;
# services.xserver.desktopManager.plasma5.enable = true;

# Define a user account. Don't forget to set a password with ‘passwd’.
	users = {
		defaultUserShell = pkgs.zsh;
		extraUsers.pinpox = {
			isNormalUser = true;
			home = "/home/pinpox";
			description = "Pablo";
			extraGroups = [ "wheel" "networkmanager" "audio"];
			shell = pkgs.zsh;
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


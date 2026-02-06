{ pkgs, ... }:
{
  # ============================================================================
  # Base Home Manager Configuration
  # ============================================================================
  # Core user environment for both desktop and headless systems

  home = {
    username = "user";
    homeDirectory = "/home/user";
    stateVersion = "24.11";
  };

  # ============================================================================
  # Core CLI Packages
  # ============================================================================

  home.packages = with pkgs; [
    fastfetch
  ];

  # ============================================================================
  # Git Configuration
  # ============================================================================

  programs.git = {
    enable = true;
    userEmail = "37084670+AKSizov@users.noreply.github.com";
    userName = "AKSizov";
    extraConfig = {
      init.defaultBranch = "master";
    };
  };

  # ============================================================================
  # Terminal & CLI Tools
  # ============================================================================

  programs.neovim.enable = true;
  programs.vim.enable = true;
  programs.htop.enable = true;
  programs.aria2.enable = true;
  programs.k9s.enable = true;
  programs.starship.enable = true;
  programs.pay-respects.enable = true;
  programs.tmux.enable = true;

  # Bash configuration with dotfiles integration
  programs.bash = {
    enable = true;
    bashrcExtra = "source ${../../dotfiles/.bashrc}";
  };

  # ============================================================================
  # System Integration
  # ============================================================================

  # Reload user services on configuration change
  systemd.user.startServices = "sd-switch";
}

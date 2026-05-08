{ pkgs, ... }:
{
  # ============================================================================
  # Base Home Manager Configuration
  # ============================================================================
  # Core user environment for both desktop and headless systems

  home = {
    username = "user";
    homeDirectory = "/home/user";
    stateVersion = "26.05";
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
    settings = {
      user = {
        email = "37084670+AKSizov@users.noreply.github.com";
        name = "AKSizov";
      };
      init.defaultBranch = "master";
    };
  };

  # ============================================================================
  # Terminal & CLI Tools
  # ============================================================================

  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
  };
  programs.vim.enable = true;
  programs.htop.enable = true;
  programs.aria2.enable = true;
  programs.k9s.enable = true;
  programs.starship.enable = true;
  programs.pay-respects.enable = true;
  programs.tmux.enable = true;

  # Bash configuration
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      # Exit immediately for non-interactive shells (SSH commands, scripts, etc.)
      [[ $- != *i* ]] && return

      # Eye candy
      if [[ $- == *i* && -x $(command -v fastfetch) ]]; then
        fastfetch < /dev/null
      fi

      # Eternal bash history.
      # ---------------------
      # Undocumented feature which sets the size to "unlimited".
      # http://stackoverflow.com/questions/9457233/unlimited-bash-history
      export HISTFILESIZE=
      export HISTSIZE=
      export HISTTIMEFORMAT="[%F %T] "
      export HISTCONTROL=ignoredups:ignorespace
      # Change the file location because certain bash sessions truncate .bash_history file upon close.
      # http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
      export HISTFILE=~/.bash_eternal_history
      # Force prompt to write history after every command.
      # http://superuser.com/questions/20900/bash-history-loss
      PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

      # Preload important programs
      #vmtouch -f $(readlink -f $(command -v firefox) | cut -d/ -f1-4)
      shopt -s autocd  # No need to type 'cd' to change directories
      shopt -s globstar  # Allow ** for recursive globbing
      shopt -s dirspell  # Auto-corrects directory names with small typos

      # Aliases
      alias ..='cd ..'
      alias ...='cd ../..'
      alias sudo='sudo ' # Allow sudo with aliases

      # Program specific aliases
      alias nrf='sudo nix flake update'
      #alias nrh='home-manager switch --flake .'
      alias nro='sudo nixos-rebuild switch --flake .'
      alias nrb='sudo nixos-rebuild boot --flake .'
      alias ssh='TERM=xterm ssh'
      alias ns='nix-shell -p'
      alias rcopy='rsync -azh --info=progress2 --no-i-r'
      alias pc='podman compose'
      alias dcr='docker compose down --remove-orphans && docker compose up -d && docker compose logs -f'
      alias dcl='docker compose logs -f'
      alias pcr='podman compose down --remove-orphans && podman compose up -d && podman compose logs -f'
      alias pcl='podman compose logs -f'
    '';
  };

  # ============================================================================
  # Nix Configuration
  # ============================================================================

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      connect-timeout = 5;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # ============================================================================
  # System Integration
  # ============================================================================

  # Reload user services on configuration change
  systemd.user.startServices = "sd-switch";
}

{
    pkgs,
    ...
}:{
  imports = [];

  home = {
    username = "user";
    homeDirectory = "/home/user";
  };

  # ===== #

  home.packages = with pkgs; [
    fastfetch
  ];

  programs.git = {
    enable = true;
    settings = {
      user.email = "37084670+AKSizov@users.noreply.github.com";
      user.name = "AKSizov";
      init.defaultBranch = "master";
    };
  };

  programs.neovim.enable = true;
  programs.aria2.enable = true;
  programs.k9s.enable = true;
  programs.starship.enable = true;
  programs.bash.enable = true;
  programs.bash.bashrcExtra = "source ${../dotfiles/.bashrc}";
  programs.pay-respects.enable = true;
  programs.tmux.enable = true;
  programs.vim.enable = true;
  programs.htop.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  
  home.stateVersion = "24.11";
}
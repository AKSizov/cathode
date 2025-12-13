# Eye candy
if [[ $- == *i* && -x $(command -v fastfetch) ]]; then
  fastfetch < /dev/null
fi

# Autolaunch Hyprland
if [ -z "${WAYLAND_DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
    dbus-run-session Hyprland > /tmp/hyprland.log
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

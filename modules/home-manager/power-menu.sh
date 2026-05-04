#!/bin/sh
# Rofi power menu — Tokyo Night themed via rofi-theme.rasi

if [ -z "$@" ]; then
  echo "🔒 Lock"
  echo "🚪 Logout"
  echo "💤 Suspend"
  echo "❄️ Hibernate"
  echo "🔄 Reboot"
  echo "⏻ Shutdown"
else
  choice=$(echo "$@" | sed 's/^[^ ]* //')
  case "$choice" in
    Lock) loginctl lock-session ;;
    Logout) loginctl terminate-user "$USER" ;;
    Suspend) systemctl suspend ;;
    Hibernate) systemctl hibernate ;;
    Reboot) systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
  esac
fi

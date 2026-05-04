#!/bin/sh
# Rofi power menu — script mode

if [ -z "${ROFI_RETV:-}" ]; then
  # Not running inside rofi — just output options
  echo "Lock"
  echo "Logout"
  echo "Suspend"
  echo "Hibernate"
  echo "Reboot"
  echo "Shutdown"
else
  # Rofi passes selection as argument
  case "$@" in
    Lock) loginctl lock-session ;;
    Logout) loginctl terminate-user "$USER" ;;
    Suspend) systemctl suspend ;;
    Hibernate) systemctl hibernate ;;
    Reboot) systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
  esac
fi

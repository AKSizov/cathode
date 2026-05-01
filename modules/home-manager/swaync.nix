{ pkgs, ... }:
{
  # ============================================================================
  # SwayNC — Notification Daemon
  # ============================================================================

  services.swaync = {
    enable = true;

    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-width = 400;
      notification-window-width = 360;
      notification-icon-size = 40;
      timeout = 5;
      timeout-low = 3;
      timeout-critical = 0;
      fit-to-screen = false;
      keyboard-shortcuts = true;
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
    };

    style = ''
      * {
        font-family: "Inter", sans-serif;
        font-size: 13px;
      }

      .notification {
        background: #24283b;
        color: #c0caf5;
        border-radius: 12px;
        border: none;
        padding: 12px;
        margin: 4px;
      }

      .notification .summary {
        color: #c0caf5;
        font-weight: 600;
        font-size: 14px;
      }

      .notification .body {
        color: #a9b1d6;
      }

      .notification.critical {
        border: 1px solid #f7768e;
      }

      .notification.critical .summary {
        color: #f7768e;
      }

      .control-center {
        background: #1a1b26;
        color: #c0caf5;
        border-radius: 16px;
        border: none;
        padding: 12px;
      }

      .control-center .notification {
        background: #24283b;
      }

      .control-center .widget-title {
        color: #c0caf5;
        font-size: 15px;
        font-weight: 600;
        padding: 8px;
      }

      .control-center .widget-title button {
        background: #24283b;
        color: #7aa2f7;
        border-radius: 8px;
        padding: 4px 12px;
        border: none;
      }

      .control-center .widget-dnd {
        color: #c0caf5;
        padding: 4px 8px;
      }

      .control-center .widget-dnd switch {
        background: #24283b;
        border-radius: 12px;
      }

      .control-center .widget-dnd switch:checked {
        background: rgba(123, 162, 247, 0.4);
      }

      .control-center .widget-dnd switch slider {
        background: #7aa2f7;
        border-radius: 10px;
      }

      .blank-window {
        background: transparent;
      }
    '';
  };
}

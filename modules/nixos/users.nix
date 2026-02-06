{ ... }:
{
  # ============================================================================
  # Default User Configuration
  # ============================================================================
  # Shared user settings for all hosts. Override in host config if needed.

  users.users.user = {
    initialPassword = "correcthorsebatterystaple";
    isNormalUser = true;
    linger = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILp3QWpsKLZtI38se2R5JatwUUJ4g6i95cTvYtYTo5Wb"
    ];
    extraGroups = [ "wheel" "video" "audio" "networkmanager" ];
  };
}

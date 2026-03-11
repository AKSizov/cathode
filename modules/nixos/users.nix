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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4D1EBWFSCjtyu9o9wTaQRfYPWIUUFk1rJMrAJ7yxr2NxyL6BJm9PQ7XvnVr4i6WfUzFOUbb/LH4BQY/3YlpIGDDwfUeGtFM9WuQAEIDmaJd5DHAHKzSDa2CZxRQaGTaZc/Omlz+oEuZFxFEIPxrfBVIWqxdANU0LvJWEKhnXUCC9jyVq1QyA8eFUsdUrC9HoTHAi8/dGYCUB+0qS2XVaL1rJ+1tJIe8PAfr/WN/BXh7vuIeuNZCHDzdAIL2v3oqw6diJFmzCZzF6uqvysX9T/f8Ody9LsD7B7TgmpLLPGf9iXOGdiG/6bebr6j1wTnxTm0dTXM2i6yatkQifNlAN6oJjCijWKpCrT2j1Rv2ZZPwzNY2+6W1YFrt/ke0PKrOC6R+J8BXoKu18ZIHkhIYM2xD8nipQ6Fq1gBAfyifXAZZRsp/Gn7OATYwVnv3x8NGVvdae3zx/pOYWs0UmVjRQTmOmiYByZph+OspLK2j24lXW1QxaFrqDmMIrtlomeP4E="
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHIGk2/yDa5Fk0NJFyj95DXpqiFsmYzhIBP9tYKQ3np0 k@oc"
    ];
    extraGroups = [ "wheel" "video" "audio" "networkmanager" ];
  };
}

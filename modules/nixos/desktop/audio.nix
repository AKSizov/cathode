{ pkgs, ... }:
{
  # PipeWire audio server
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Disable HDA power saving — smart amplifiers on modern ThinkPads
  # lose connection to the codec when snd_hda_intel sleeps, causing
  # quiet/distorted output. Costs ~0.5W idle but fixes audio quality.
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0
  '';

  # EasyEffects preset for T14 Gen 3 speakers — replaces Dolby Atmos
  # processing that Windows does in the Realtek driver. Bass enhancer +
  # high-pass filter + 12-band EQ + multiband compressor + stereo widener
  # + limiter. autoload via EasyEffects → Presets Autoloading after first
  # rebuild, or manually select "T14-Gen3-Speakers" in the EE preset menu.
  # easyeffects service is enabled in home-manager/desktop.nix
}

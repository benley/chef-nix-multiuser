default['nix']['version'] = '1.11.9'

default['nix']['tarball_checksum'] =
  'ae001425af88c0fef645988ec88892110c972cf880216586b5b3a5246e3dd572'

default['nix']['mirror'] = 'https://nixos.org/releases/nix'

default['nix']['trusted_binary_caches'] = [
  'https://cache.nixos.org',
  'https://hydra.nixos.org'
]

default['nix']['binary_cache_public_keys'] = [
  'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=',
  'hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs='
]

default['nix']['build_use_sandbox'] = true

default['nix']['build_users_group'] = 'nixbld'

default['nix']['extra_binary_caches'] = []

# Extra things for /etc/nix/nix.conf
default['nix']['extra_nix_options'] = {}

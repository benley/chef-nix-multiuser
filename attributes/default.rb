default['nix']['version'] = '1.9'

default['nix']['url'] =
  'https://nixos.org/releases/nix/nix-1.9/nix-1.9-x86_64-linux.tar.bz2'

default['nix']['url_checksum'] =
  '5c76611c631e79aef5faf3db2d253237998bbee0f61fa093f925fa32203ae32b'

default['nix']['tarball_filename'] = 'nix-1.9-x86_64-linux.tar.bz2'

default['nix']['trusted_binary_caches'] = [
  'https://cache.nixos.org',
  'https://hydra.nixos.org'
]

default['nix']['extra_binary_caches'] = []

# Extra things for /etc/nix/nix.conf
default['nix']['extra_nix_options'] = {}

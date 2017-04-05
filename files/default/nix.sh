export NIXPKGS_CONFIG="/etc/nix/nixpkgs-config.nix"
export NIX_OTHER_STORES="/run/nix/remote-stores/*/nix"
export NIX_USER_PROFILE_DIR="/nix/var/nix/profiles/per-user/$USER"
export NIX_PROFILES="/nix/var/nix/profiles/default $HOME/.nix-profile"
export NIX_PATH="/nix/var/nix/profiles/per-user/root/channels"
export PATH="$HOME/.nix-profile/bin:$HOME/.nix-profile/sbin:/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:$PATH"

# A few hacks to get things using the system x509 ca bundle
export OPENSSL_X509_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
export GIT_SSL_CAINFO="/etc/ssl/certs/ca-certificates.crt"
export CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"

# Use the nix daemon for multi-user builds
if [ "$USER" != root -o ! -w /nix/var/nix/db ]; then
  export NIX_REMOTE=daemon
fi

# Set up the per-user profile.
mkdir -m 0755 -p "$NIX_USER_PROFILE_DIR"
if test "$(stat --printf '%u' "$NIX_USER_PROFILE_DIR")" != "$(id -u)"; then
    echo "WARNING: bad ownership on $NIX_USER_PROFILE_DIR" >&2
fi

if [ -w "$HOME" ]; then
  # Set the default profile.
  if ! [ -L "$HOME/.nix-profile" ]; then
    if [ "$USER" != root ]; then
      ln -s "$NIX_USER_PROFILE_DIR/profile" "$HOME/.nix-profile"
    else
      # Root installs in the system-wide profile by default.
      ln -s /nix/var/nix/profiles/default "$HOME/.nix-profile"
    fi
  fi

  # Create the per-user garbage collector roots directory.
  NIX_USER_GCROOTS_DIR=/nix/var/nix/gcroots/per-user/$USER
  mkdir -m 0755 -p "$NIX_USER_GCROOTS_DIR"
  if test "$(stat --printf '%u' "$NIX_USER_GCROOTS_DIR")" != "$(id -u)"; then
    echo "WARNING: bad ownership on $NIX_USER_GCROOTS_DIR" >&2
  fi

  # Set up a default Nix expression from which to install stuff.
  if [ ! -e "$HOME/.nix-defexpr" -o -L "$HOME/.nix-defexpr" ]; then
    rm -f "$HOME/.nix-defexpr"
    mkdir "$HOME/.nix-defexpr"
    if [ "$USER" != root ]; then
        ln -s /nix/var/nix/profiles/per-user/root/channels "$HOME/.nix-defexpr/channels_root"
    fi
  fi

  # Subscribe the to the Nixpkgs channel by default.
  if [ ! -e "$HOME/.nix-channels" ]; then
      echo "http://nixos.org/channels/nixpkgs-unstable nixpkgs" > "$HOME/.nix-channels"
  fi

  # Append ~/.nix-defexpr/channels/nixpkgs to $NIX_PATH so that
  # <nixpkgs> paths work when the user has fetched the Nixpkgs
  # channel.
  export NIX_PATH="${NIX_PATH:+$NIX_PATH:}nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs"
fi

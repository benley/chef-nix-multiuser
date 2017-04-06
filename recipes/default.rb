# nix::default

(1..10).each do |i|
  user "nixbld#{i}" do
    system true
    group 'nogroup'
    home  '/var/empty'
    shell '/bin/false'
  end
end

group 'nixbld' do
  system true
  members((1..10).map { |i| "nixbld#{i}" })
end

tarball_basename =
  "nix-#{node['nix']['version']}-#{node['kernel']['machine']}-linux.tar.bz2"
nix_url =
  "#{node['nix']['mirror']}/nix-#{node['nix']['version']}/#{tarball_basename}"
tarball_path =
  "#{Chef::Config[:file_cache_path]}/#{tarball_basename}"

remote_file 'nix_tarball' do
  path tarball_path
  source nix_url
  checksum node['nix']['tarball_checksum']
  mode '00644'
end

directory '/nix' do
  owner 'root'
  group 'root'
  mode '00755'
end

# Content-hashed! Hopefully the file cache gets cleaned up now and then.
unpack_dir =
  "#{Chef::Config[:file_cache_path]}/nix-bootstrap" \
  "/#{node['nix']['tarball_checksum']}"

directory unpack_dir do
  recursive true
  owner 'root'
  group 'root'
  mode '00755'
end

execute 'unpack' do
  command "tar -C #{unpack_dir} --strip-components=1 -xjf '#{tarball_path}'"
  not_if { ::File.exist? '/nix/store' }
end

execute 'install' do
  cwd unpack_dir
  user 'root'
  command 'export USER=root HOME=/root; ./install'
  creates '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'
end

directory '/nix/store' do
  recursive true
  owner 'root'
  group node['nix']['build_users_group']
  mode  '1775'
end

directory '/nix/var/nix/profiles' do
  recursive true
  owner 'root'
  group 'root'
  mode  '1777'
end

directory '/nix/var/nix/profiles/per-user' do
  recursive true
  owner 'root'
  group 'root'
  mode  '1777'
end

directory '/nix/var/nix/gcroots/per-user' do
  recursive true
  owner 'root'
  group 'root'
  mode  '1777'
end

# NIX DAEMON

directory '/etc/nix'

template '/etc/nix/nix.conf' do
  variables node['nix']
  if node['platform_version'].to_f <= 14.04
    notifies :restart, 'service[nix-daemon]'
    # with systemd we can use socket activation
  end
end

execute 'poke upstart' do
  command 'initctl reload-configuration'
  action :nothing
end

cookbook_file '/etc/profile.d/nix.sh'

link '/etc/init/nix-daemon.conf' do
  to '/nix/var/nix/profiles/default/etc/init/nix-daemon.conf'
  notifies :run, 'execute[poke upstart]', :immediately
  notifies :restart, 'service[nix-daemon]'
  action :nothing if node['platform_version'].to_f > 14.04
end

link '/lib/systemd/system/nix-daemon.socket' do
  to '/nix/var/nix/profiles/default/lib/systemd/system/nix-daemon.socket'
  notifies :restart, 'service[nix-daemon.socket]'
  action :nothing if node['platform_version'].to_f <= 14.04
end

link '/lib/systemd/system/nix-daemon.service' do
  to '/nix/var/nix/profiles/default/lib/systemd/system/nix-daemon.service'
  action :nothing if node['platform_version'].to_f <= 14.04
end

service 'nix-daemon' do
  if node['platform_version'].to_f <= 14.04
    provider Chef::Provider::Service::Upstart
    action :start
  else
    provider Chef::Provider::Service::Systemd
    action :nothing # Socket activation
  end
end

service 'nix-daemon.socket' do
  if node['platform_version'].to_f > 14.04
    action :start
  else
    action :nothing
  end
end

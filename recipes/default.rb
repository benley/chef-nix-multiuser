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

nix_tarball =
  "#{Chef::Config[:file_cache_path]}/#{node['nix']['tarball_filename']}"

remote_file 'nix_tarball' do
  path nix_tarball
  source node['nix']['url']
  checksum node['nix']['url_checksum']
  mode '00644'
end

directory '/nix' do
  owner 'root'
  group 'root'
  mode '00755'
end

execute 'unpack' do
  cwd Chef::Config[:file_cache_path]
  command "tar xjf #{nix_tarball}"
  not_if { ::File.exist? '/nix/store' }
end

execute 'install' do
  cwd "#{Chef::Config[:file_cache_path]}/nix-1.8-x86_64-linux"
  user 'root'
  command 'export USER=root HOME=/root; ./install'
  creates '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'
end

directory '/nix/store' do
  recursive true
  owner 'root'
  group 'nixbld'
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
  notifies :restart, 'service[nix-daemon]'
end

cookbook_file '/etc/profile.d/nix.sh'

cookbook_file '/etc/init/nix-daemon.conf' do
  notifies :restart, 'service[nix-daemon]'
end

service 'nix-daemon' do
  provider Chef::Provider::Service::Upstart
  action [:start]
end

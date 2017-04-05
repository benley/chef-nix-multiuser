require 'serverspec'

set :backend, :exec

describe service('nix-daemon') do
  it { should be_running }
end

describe group('nixbld') do
  it { should exist }
end

(1..10).each do |u|
  describe user("nixbld#{u}") do
    it { should belong_to_group 'nixbld' }
  end
end

describe file('/nix/store') do
  it { should be_directory }
  it { should be_mode 1775 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'nixbld' }
end

describe file('/nix/var/nix/daemon-socket/socket') do
  it { should be_socket }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 666 }
end

describe command('su -l -c "nix-env -e bash"') do
  its(:exit_status) { should eq 0 }
end

describe command('su -l -c "nix-env -i bash"') do
  its(:exit_status) { should eq 0 }
end

describe command('su -l -c "which bash"') do
  its(:stdout) { should match(/\/\.nix-profile/) }
end

# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager::ifc::connection' do
  let(:title) { 'eth0conn' }
  let(:params) do
    { interface_name: 'eth0', ipv6_method: 'ignore', ipv4_method: 'manual', ipv4_address: '10.0.0.5/24', ipv4_gateway: '10.0.0.1' }
  end

  each_test_os do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_file('/etc/NetworkManager/system-connections/eth0conn.nmconnection').with_mode('0600') }
    end
  end
end

describe 'networkmanager::ifc::connection' do
  let(:title) { 'eth0conn' }
  let(:facts) { nm_test_facts('AlmaLinux', '9') }
  let(:params) do
    { interface_name: 'eth0', ipv6_method: 'manual', ipv6_address: '2001:db8::5/64',
      ipv4_dns: ['8.8.8.8', '8.8.4.4'], ipv6_dns: ['2001:db8::53'] }
  end

  it { is_expected.to contain_file('/etc/NetworkManager/system-connections/eth0conn.nmconnection').with_content(%r{^dns=8\.8\.8\.8;8\.8\.4\.4;$}) }
  it { is_expected.to contain_file('/etc/NetworkManager/system-connections/eth0conn.nmconnection').with_content(%r{^dns=2001:db8::53;$}) }
end

describe 'networkmanager::ifc::connection' do
  let(:title) { 'eth0conn' }
  let(:facts) { nm_test_facts('AlmaLinux', '9') }
  let(:params) do
    { interface_name: 'eth0', ipv6_method: 'ignore',
      additional_config: { 'ipv4' => { 'dns-search' => ['example.com', 'example.org'] }, 'x' => { 'y' => 'a\\b' } } }
  end

  it { is_expected.to contain_file('/etc/NetworkManager/system-connections/eth0conn.nmconnection').with_content(%r{^dns-search=example\.com;example\.org;$}) }
  it { is_expected.to contain_file('/etc/NetworkManager/system-connections/eth0conn.nmconnection').with_content(%r{^y=a\\\\b$}) }
end

describe 'networkmanager::ifc::connection' do
  let(:title) { 'eth0conn' }
  let(:facts) { nm_test_facts('AlmaLinux', '9') }
  let(:file) { '/etc/NetworkManager/system-connections/eth0conn.nmconnection' }
  let(:base) { { interface_name: 'eth0', ipv4_method: 'manual', ipv6_method: 'manual' } }

  context 'with a single address' do
    let(:params) { base.merge(ipv4_address: '10.0.0.5/24', ipv6_address: '2001:db8::5/64') }

    it { is_expected.to contain_file(file).with_content(%r{^address=10\.0\.0\.5/24$}) }
    it { is_expected.to contain_file(file).with_content(%r{^address=2001:db8::5/64$}) }
  end

  ['10.0.0.5/24;10.0.1.5/24', ['10.0.0.5/24', '10.0.1.5/24']].each do |addresses|
    context "with multiple IPv4 addresses as #{addresses.class}" do
      let(:params) { base.merge(ipv4_address: addresses, ipv6_address: %w[2001:db8::5/64 fd00::5/64], ipv4_gateway: '10.0.0.1') }

      it { is_expected.to contain_file(file).with_content(%r{^address1=10\.0\.0\.5/24\naddress2=10\.0\.1\.5/24\n}) }
      it { is_expected.to contain_file(file).with_content(%r{^address1=2001:db8::5/64\naddress2=fd00::5/64\n}) }
      it { is_expected.not_to contain_file(file).with_content(%r{^address=}) }
      it { is_expected.to contain_file(file).with_content(%r{^gateway=10\.0\.0\.1\naddress1=}) }
    end
  end
end

describe 'networkmanager::ifc::connection' do
  let(:title) { 'eth0conn' }
  let(:facts) { nm_test_facts('AlmaLinux', '9') }
  let(:file) { '/etc/NetworkManager/system-connections/eth0conn.nmconnection' }

  context 'with the IPv4 disabled and the IPv6 ignored' do
    let(:params) do
      { interface_name: 'eth0', ipv4_method: 'disabled', ipv4_address: '10.0.0.5/24', ipv4_dns: '1.1.1.1;',
        ipv6_method: 'ignore', ipv6_address: '2001:db8::5/64' }
    end

    it { is_expected.to contain_file(file).with_content(%r{\[ipv4\]\nmethod=disabled\n\n\[ipv6\]\nmethod=ignore\n}) }
    it { is_expected.not_to contain_file(file).with_content(%r{^(address|dns|may-fail|addr-gen-mode|ip6-privacy)}) }
  end
end

describe 'networkmanager::ifc::connection' do
  let(:facts) { nm_test_facts('AlmaLinux', '9') }
  let(:base) { { ipv4_method: 'auto', ipv6_method: 'ignore' } }

  def keyfile(title)
    "/etc/NetworkManager/system-connections/#{title}.nmconnection"
  end

  context 'without the interface name and the mac address' do
    let(:title) { 'ens192' }
    let(:params) { base }

    it { is_expected.to contain_file(keyfile('ens192')).with_content(%r{^interface-name=ens192$}) }
  end

  context 'without the interface name and the mac address and with the state down' do
    let(:title) { 'ens192' }
    let(:params) { base.merge(state: 'down') }

    it 'shuts the link down using the derived interface name' do
      commands = catalogue.resources.select { |r| r.type == 'Exec' && r.title.start_with?('shutdown link of connection') }.map { |r| r[:command] }
      expect(commands).to eq(['ip link set dev ens192 down'])
    end
  end

  context 'with the mac address only' do
    let(:title) { 'ens192' }
    let(:params) { base.merge(mac_address: 'aa:bb:cc:dd:ee:ff') }

    it { is_expected.to contain_file(keyfile('ens192')).with_content(%r{^mac-address=aa:bb:cc:dd:ee:ff$}) }
    it { is_expected.not_to contain_file(keyfile('ens192')).with_content(%r{^interface-name=}) }
  end

  context 'with the interface name' do
    let(:title) { 'ens192' }
    let(:params) { base.merge(interface_name: 'eth7') }

    it { is_expected.to contain_file(keyfile('ens192')).with_content(%r{^interface-name=eth7$}) }
    it { is_expected.not_to contain_file(keyfile('ens192')).with_content(%r{^interface-name=ens192$}) }
  end

  context 'with a different id' do
    let(:title) { 'ens192' }
    let(:params) { base.merge(id: 'uplink') }

    it { is_expected.to contain_file(keyfile('uplink')).with_content(%r{^interface-name=ens192$}) }
  end

  context 'with a title which is not usable as the interface name' do
    ['a-title-longer-than-15', 'with space', 'a/b/c'].each do |bad_title|
      context "'#{bad_title}'" do
        let(:title) { bad_title }
        let(:params) { base.merge(id: 'uplink') }

        it { is_expected.to compile.and_raise_error(%r{can not be used as the interface name}) }
      end
    end
  end

  context 'with another type of the connection' do
    let(:title) { 'wlan-home' }
    let(:params) { base.merge(type: 'wifi') }

    it { is_expected.to contain_file(keyfile('wlan-home')) }
    it { is_expected.not_to contain_file(keyfile('wlan-home')).with_content(%r{^interface-name=}) }
  end
end

describe 'networkmanager::ifc::connection' do
  let(:title) { 'upstream' }
  let(:facts) { nm_test_facts('AlmaLinux', '9') }
  let(:file) { '/etc/NetworkManager/system-connections/upstream.nmconnection' }
  let(:base) { { interface_name: 'ens4f0', ipv4_method: 'manual', ipv4_address: '10.10.110.57/24', ipv4_gateway: '10.10.110.1' } }

  context 'with the default IPv6 method auto, the mac address and no DUID' do
    let(:params) { base.merge(mac_address: 'aa:bb:cc:dd:ee:ff') }

    it { is_expected.to contain_file(file).with_content(%r{^dhcp-duid=00:03:00:01:aa:bb:cc:dd:ee:ff$}) }
  end

  context 'with the default IPv6 method auto and neither the mac address nor the DUID (issue 29)' do
    let(:params) { base }

    it { is_expected.to compile.and_raise_error(%r{no mac_address was supplied.*ipv6_dhcp_duid_default}m) }

    context 'and the class default unset' do
      let(:pre_condition) { "class { 'networkmanager': ipv6_dhcp_duid_default => 'unset' }" }

      it { is_expected.to compile }
      it { is_expected.not_to contain_file(file).with_content(%r{dhcp-duid}) }
    end

    context 'and the class default ll' do
      let(:pre_condition) { "class { 'networkmanager': ipv6_dhcp_duid_default => 'll' }" }

      it { is_expected.to contain_file(file).with_content(%r{^dhcp-duid=ll$}) }
    end

    context 'and the DUID unset for the connection while the class default is auto' do
      let(:params) { base.merge(ipv6_dhcp_duid: 'unset') }

      it { is_expected.to compile }
      it { is_expected.not_to contain_file(file).with_content(%r{dhcp-duid}) }
    end
  end

  context 'with a DUID of the connection' do
    let(:params) { base.merge(ipv6_dhcp_duid: 'stable-ll') }

    it { is_expected.to contain_file(file).with_content(%r{^dhcp-duid=stable-ll$}) }
  end

  context 'with an invalid DUID' do
    let(:params) { base.merge(ipv6_dhcp_duid: '00:22:66::52') }

    it { is_expected.to compile.and_raise_error(%r{ipv6_dhcp_duid}) }
  end
end

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

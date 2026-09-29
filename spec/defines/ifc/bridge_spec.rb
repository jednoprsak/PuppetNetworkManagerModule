# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager::ifc::bridge' do
  let(:title) { 'br0' }
  let(:params) do
    { ipv6_method: 'ignore' }
  end

  each_test_os do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_file('/etc/NetworkManager/system-connections/br0.nmconnection').with_mode('0600') }
    end
  end
end

describe 'networkmanager::ifc::bridge' do
  let(:title) { 'br1' }
  let(:facts) { nm_test_facts('AlmaLinux', '9') }
  let(:params) { { ipv6_method: 'ignore', ipv4_method: 'manual', ipv4_address: '10.0.0.5/24', ipv4_dns: '1.1.1.1;' } }

  it { is_expected.to contain_file('/etc/NetworkManager/system-connections/br1.nmconnection').with_content(%r{^dns=1\.1\.1\.1;$}) }
end

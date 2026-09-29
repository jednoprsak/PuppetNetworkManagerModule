# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager::ifc::vlan' do
  let(:title) { 'vlan100' }
  let(:params) do
    { vlan_id: 100, vlan_parent: 'eth0conn' }
  end

  each_test_os do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_file('/etc/NetworkManager/system-connections/vlan100.nmconnection').with_mode('0600') }
    end
  end
end

describe 'networkmanager::ifc::vlan' do
  let(:title) { 'vlan100' }
  let(:facts) { nm_test_facts('AlmaLinux', '9') }
  let(:file) { '/etc/NetworkManager/system-connections/vlan100.nmconnection' }

  # NetworkManager expects the plain UUID in vlan.parent, a "UUID=" prefix is rejected by it
  context 'with a connection UUID as the parent' do
    let(:params) { { vlan_id: 100, vlan_parent: '0f2a1c3e-1111-4222-8333-444455556666' } }

    it { is_expected.to contain_file(file).with_content(%r{^parent=0f2a1c3e-1111-4222-8333-444455556666$}) }
    it { is_expected.not_to contain_file(file).with_content(%r{UUID=}) }
  end

  context 'with a connection id as the parent' do
    let(:params) { { vlan_id: 100, vlan_parent: 'eth0conn' } }

    it { is_expected.to contain_file(file).with_content(%r{^parent=\h{8}-\h{4}-\h{4}-\h{4}-\h{12}$}) }
    it { is_expected.not_to contain_file(file).with_content(%r{^parent=eth0conn$}) }
  end
end

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

# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager::ifc::bond::slave' do
  let(:title) { 'eth1slave' }
  let(:params) do
    { master: 'bond0', interface_name: 'eth1' }
  end

  each_test_os do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_file('/etc/NetworkManager/system-connections/eth1slave.nmconnection').with_mode('0600') }
    end
  end
end

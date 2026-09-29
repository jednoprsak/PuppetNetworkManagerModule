# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager::ifc::fallback' do
  let(:title) { 'fallback0' }
  let(:params) do
    { config: { 'ipv4' => { 'method' => 'auto' } } }
  end

  each_test_os do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_file('/etc/NetworkManager/system-connections/fallback0.nmconnection').with_mode('0600') }
    end
  end
end

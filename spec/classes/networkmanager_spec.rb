# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager' do
  each_test_os do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('networkmanager::os') }
      it { is_expected.to contain_class('networkmanager::install') }
      it { is_expected.to contain_class('networkmanager::config') }
      it { is_expected.to contain_class('networkmanager::service') }
      it { is_expected.to contain_file('/etc/NetworkManager/NetworkManager.conf').with_content(%r{^\[main\]$}) }
      it { is_expected.to contain_service('NetworkManager.service').with_ensure('running').with_enable(true) }

      case os_facts['os']['family']
      when 'Debian'
        it { is_expected.to contain_package('network-manager') }
      when 'RedHat'
        it { is_expected.to contain_package('NetworkManager') }
      when 'Archlinux'
        it { is_expected.to contain_package('networkmanager') }
      when 'Gentoo'
        it { is_expected.to contain_package('net-misc/networkmanager') }
      end
    end
  end

  context 'with install_package => false' do
    let(:facts) { nm_test_facts('AlmaLinux', '9') }
    let(:params) { { install_package: false } }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.not_to contain_package('NetworkManager') }
  end

  context 'with wait_online => false' do
    let(:facts) { nm_test_facts('AlmaLinux', '9') }
    let(:params) { { wait_online: false } }

    it { is_expected.to contain_service('NetworkManager-wait-online.service').with_ensure('stopped').with_enable(false) }
  end

  context 'with an unsupported OS family' do
    let(:facts) { nm_test_facts('Solaris', '11', 'Solaris') }

    it { is_expected.to compile.and_raise_error(%r{OS family 'Solaris' is not supported}) }
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager::ipv6_disable_version' do
  let(:pre_condition) { 'include networkmanager' }

  context 'with NetworkManager 1.40' do
    let(:facts) { nm_test_facts('AlmaLinux', '9') }

    it { is_expected.to run.with_params('disabled').and_return('disabled') }
    it { is_expected.to run.with_params('auto').and_return('auto') }
  end

  context 'with NetworkManager older than 1.20' do
    let(:facts) { nm_test_facts('AlmaLinux', '8', 'RedHat', { 'major' => '1', 'minor' => '18' }) }

    it { is_expected.to run.with_params('disabled').and_return('ignore') }
    it { is_expected.to run.with_params('manual').and_return('manual') }
  end

  context 'before NetworkManager is installed (no fact)' do
    let(:facts) { nm_test_facts('AlmaLinux', '9').reject { |key, _| 'networkmanager' == key } }

    it { is_expected.to run.with_params('disabled').and_return('disabled') }
  end
end

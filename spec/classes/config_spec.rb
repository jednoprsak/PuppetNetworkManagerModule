# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager::config' do
  let(:pre_condition) { 'include networkmanager' }

  each_test_os do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
    end
  end
end

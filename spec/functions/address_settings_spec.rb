# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager::address_settings' do
  it { is_expected.to run.with_params(nil).and_return({}) }
  it { is_expected.to run.with_params('10.0.0.5/24').and_return({ 'address' => '10.0.0.5/24' }) }
  it { is_expected.to run.with_params('10.0.0.5/24,10.0.0.1').and_return({ 'address' => '10.0.0.5/24,10.0.0.1' }) }
  it { is_expected.to run.with_params(['10.0.0.5/24']).and_return({ 'address' => '10.0.0.5/24' }) }
  it { is_expected.to run.with_params(['10.0.0.5/24', '10.0.1.5/24']).and_return({ 'address1' => '10.0.0.5/24', 'address2' => '10.0.1.5/24' }) }
  it { is_expected.to run.with_params('10.0.0.5/24;10.0.1.5/24').and_return({ 'address1' => '10.0.0.5/24', 'address2' => '10.0.1.5/24' }) }
  it { is_expected.to run.with_params('10.0.0.5/24;10.0.1.5/24;').and_return({ 'address1' => '10.0.0.5/24', 'address2' => '10.0.1.5/24' }) }
  it { is_expected.to run.with_params(%w[a b c]).and_return({ 'address1' => 'a', 'address2' => 'b', 'address3' => 'c' }) }
end

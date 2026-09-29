# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager::dns_list' do
  it { is_expected.to run.with_params(nil).and_return(nil) }
  it { is_expected.to run.with_params('8.8.8.8;').and_return('8.8.8.8;') }
  it { is_expected.to run.with_params(['8.8.8.8']).and_return('8.8.8.8;') }
  it { is_expected.to run.with_params(['8.8.8.8', '8.8.4.4']).and_return('8.8.8.8;8.8.4.4;') }
  it { is_expected.to run.with_params(['2001:db8::53', '2001:db8::54']).and_return('2001:db8::53;2001:db8::54;') }
end

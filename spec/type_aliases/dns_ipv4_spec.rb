# frozen_string_literal: true

require 'spec_helper'

describe 'Networkmanager::DNS_IPV4' do
  it { is_expected.to allow_value('8.8.8.8') }
  it { is_expected.to allow_value('8.8.8.8;') }
  it { is_expected.to allow_value('8.8.8.8;8.8.4.4;') }
  it { is_expected.to allow_value('1.1.1.1;2.2.2.2;3.3.3.3;4.4.4.4;255.255.255.255') }
  it { is_expected.to allow_value(['8.8.8.8', '8.8.4.4']) }

  it { is_expected.not_to allow_value('not an address') }
  it { is_expected.not_to allow_value('') }
  it { is_expected.not_to allow_value('8.8.8.8,8.8.4.4') }
  it { is_expected.not_to allow_value('8.8.8.256;') }
  it { is_expected.not_to allow_value('8.8.8;') }
  it { is_expected.not_to allow_value('1.1.1.1;2.2.2.2;3.3.3.3;4.4.4.4;5.5.5.5;6.6.6.6;') }
  it { is_expected.not_to allow_value(['8.8.8.8/24']) }
  it { is_expected.not_to allow_value(['2001:db8::53']) }
  it { is_expected.not_to allow_value([]) }
end

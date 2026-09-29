# frozen_string_literal: true

require 'spec_helper'

describe 'Networkmanager::DNS_IPV6' do
  it { is_expected.to allow_value('2001:db8:0:0:0:0:0:53') }
  it { is_expected.to allow_value('2001:db8::53') }
  it { is_expected.to allow_value('2001:db8::53;') }
  it { is_expected.to allow_value('2001:db8::53;fd00::1;') }
  it { is_expected.to allow_value('::1;2001:db8::53;fd00::1;fd00::2;fd00::3') }
  it { is_expected.to allow_value(['2001:db8::53', 'fd00::1']) }

  it { is_expected.not_to allow_value('not an address') }
  it { is_expected.not_to allow_value('2001:db8::53,fd00::1') }
  it { is_expected.not_to allow_value('::1;::2;::3;::4;::5;::6;') }
  it { is_expected.not_to allow_value(['2001:db8::53/64']) }
  it { is_expected.not_to allow_value(['1.1.1.1']) }
  it { is_expected.not_to allow_value([]) }
end

# frozen_string_literal: true

require 'spec_helper'

describe 'Networkmanager::IPV4_CIDR' do
  it { is_expected.to allow_value('192.168.1.12/24') }
  it { is_expected.to allow_value('192.168.1.12/24,192.168.1.1') }
  it { is_expected.to allow_value('10.0.0.5/32,10.0.0.1') }
  it { is_expected.to allow_value('0.0.0.0/0') }

  it { is_expected.not_to allow_value('192.168.1.12') }
  it { is_expected.not_to allow_value('192.168.1.12/33') }
  it { is_expected.not_to allow_value('192.168.1.256/24') }
  it { is_expected.not_to allow_value('192.168.1.12/24,') }
  it { is_expected.not_to allow_value('192.168.1.12/24,192.168.1.256') }
  it { is_expected.not_to allow_value('192.168.1.12/24;192.168.1.1') }
  it { is_expected.not_to allow_value('not an address') }
end

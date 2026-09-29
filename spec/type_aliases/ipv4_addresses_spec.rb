# frozen_string_literal: true

require 'spec_helper'

describe 'Networkmanager::IPV4_ADDRESSES' do
  it { is_expected.to allow_value('10.0.0.5/24') }
  it { is_expected.to allow_value('10.0.0.5/24,10.0.0.1') }
  it { is_expected.to allow_value(['10.0.0.5/24', '10.0.1.5/24']) }
  it { is_expected.to allow_value('10.0.0.5/24;10.0.1.5/24') }
  it { is_expected.to allow_value('10.0.0.5/24;10.0.1.5/24;10.0.2.5/24;') }

  it { is_expected.not_to allow_value('10.0.0.5') }
  it { is_expected.not_to allow_value('10.0.0.5/24;10.0.1.5') }
  it { is_expected.not_to allow_value('10.0.0.5/24,10.0.1.5/24') }
  it { is_expected.not_to allow_value(['10.0.0.5']) }
  it { is_expected.not_to allow_value([]) }
end

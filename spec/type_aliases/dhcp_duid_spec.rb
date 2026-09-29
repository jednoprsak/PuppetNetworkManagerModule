# frozen_string_literal: true

require 'spec_helper'

describe 'Networkmanager::DHCP_DUID' do
  %w[auto unset lease ll llt stable-ll stable-llt stable-uuid 00:03:00:01:aa:bb:cc:dd:ee:ff 00:aa].each do |value|
    it { is_expected.to allow_value(value) }
  end

  ['', 'fail', 'LL', 'll ', '00:22:66::52:54', 'aa:bb:cc:', 'zz:zz', 12].each do |value|
    it { is_expected.not_to allow_value(value) }
  end
end

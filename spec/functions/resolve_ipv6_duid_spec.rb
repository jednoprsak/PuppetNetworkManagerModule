# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager::resolve_ipv6_duid' do
  let(:facts) { nm_test_facts('AlmaLinux', '9') }
  let(:pre_condition) { 'include networkmanager' }
  let(:mac) { 'AA:BB:CC:DD:EE:FF' }
  let(:generated) { '00:03:00:01:aa:bb:cc:dd:ee:ff' }

  def resolve(duid, mac_address, method = 'auto', ensure_state = 'present', state = 'up')
    subject.execute(duid, mac_address, method, ensure_state, state, 'conn')
  end

  context 'with the default of the class' do
    it('builds the DUID from the mac address') { expect(resolve(nil, mac)).to eq(generated) }
    it('fails without the mac address') { expect { resolve(nil, nil) }.to raise_error(%r{no mac_address was supplied}) }
    it('gives the connection value precedence') { expect(resolve('ll', mac)).to eq('ll') }
    it('does not write it when the connection says unset') { expect(resolve('unset', nil)).to be_nil }
    it('uses the literal DUID of the connection') { expect(resolve('00:aa:bb', nil)).to eq('00:aa:bb') }
    it('builds an explicit auto too') { expect(resolve('auto', mac)).to eq(generated) }
  end

  context 'when nothing should be written' do
    it('for the manual method') { expect(resolve(nil, nil, 'manual')).to be_nil }
    it('for the ignored IPv6') { expect(resolve('auto', nil, 'ignore')).to be_nil }
    it('for the connection which is down') { expect(resolve(nil, nil, 'auto', 'present', 'down')).to be_nil }
    it('for the absent connection') { expect(resolve(nil, nil, 'auto', 'absent')).to be_nil }
    it('for the dhcp method it is written') { expect(resolve(nil, mac, 'dhcp')).to eq(generated) }
  end

  {
    'unset' => nil,
    'll' => 'll',
    'stable-uuid' => 'stable-uuid',
    '00:03:00:01:11:22:33:44:55:66' => '00:03:00:01:11:22:33:44:55:66',
  }.each do |default, expected|
    context "with the class default #{default}" do
      let(:pre_condition) { "class { 'networkmanager': ipv6_dhcp_duid_default => '#{default}' }" }

      it('applies to the connection without the DUID and the mac address') { expect(resolve(nil, nil)).to eq(expected) }
      it('does not override the connection value') { expect(resolve('lease', nil)).to eq('lease') }
    end
  end

  context 'with the class default auto and a different prefix' do
    let(:pre_condition) { "class { 'networkmanager': duid_prefix => '00:01:00:01' }" }

    it { expect(resolve(nil, mac)).to eq('00:01:00:01:aa:bb:cc:dd:ee:ff') }
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager::prepare_ipv4_config' do
  it 'writes only the method when the IPv4 is disabled' do
    is_expected.to run.with_params('disabled', '10.0.0.5/24', '10.0.0.1', '1.1.1.1;', true)
                      .and_return({ 'ipv4' => { 'method' => 'disabled' } })
  end

  it 'writes the details otherwise, in a fixed order' do
    result = subject.execute('manual', %w[10.0.0.5/24 10.0.1.5/24], '10.0.0.1', %w[1.1.1.1 8.8.8.8], false)
    expect(result).to eq({ 'ipv4' => { 'method' => 'manual', 'may-fail' => false, 'gateway' => '10.0.0.1',
                                        'address1' => '10.0.0.5/24', 'address2' => '10.0.1.5/24', 'dns' => '1.1.1.1;8.8.8.8;' } })
    expect(result['ipv4'].keys).to eq(%w[method may-fail gateway address1 address2 dns])
  end

  it { is_expected.to run.with_params('auto', nil, nil, nil, true).and_return({ 'ipv4' => { 'method' => 'auto', 'may-fail' => true } }) }
end

describe 'networkmanager::prepare_ipv6_config' do
  %w[ignore disabled].each do |method|
    it "writes only the method for #{method}" do
      is_expected.to run.with_params(method, '2001:db8::5/64', '2001:db8::1', nil, 0, 0, true, nil)
                        .and_return({ 'ipv6' => { 'method' => method } })
    end
  end

  it 'writes the details otherwise' do
    is_expected.to run.with_params('auto', nil, nil, nil, 1, 2, false, '00:03:00:01:aa:bb:cc:dd:ee:ff')
                      .and_return({ 'ipv6' => { 'method' => 'auto', 'addr-gen-mode' => 1, 'ip6-privacy' => 2, 'may-fail' => false,
                                                'dhcp-duid' => '00:03:00:01:aa:bb:cc:dd:ee:ff' } })
  end
end

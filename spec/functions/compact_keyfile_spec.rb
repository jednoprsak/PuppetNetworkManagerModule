# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager::compact_keyfile' do
  it { is_expected.to run.with_params({}).and_return({}) }

  it 'drops undefined settings' do
    is_expected.to run.with_params({ 'ipv4' => { 'method' => 'auto', 'gateway' => nil } })
                      .and_return({ 'ipv4' => { 'method' => 'auto' } })
  end

  it 'drops sections left empty' do
    is_expected.to run.with_params({ 'ethernet' => { 'mac-address' => nil }, 'ipv4' => { 'method' => 'auto' } })
                      .and_return({ 'ipv4' => { 'method' => 'auto' } })
  end

  it 'keeps false and zero values' do
    is_expected.to run.with_params({ 'ipv6' => { 'may-fail' => false, 'addr-gen-mode' => 0 } })
                      .and_return({ 'ipv6' => { 'may-fail' => false, 'addr-gen-mode' => 0 } })
  end

  it 'keeps the order of sections and settings' do
    result = subject.execute({ 'b' => { 'z' => 1, 'a' => 2 }, 'a' => { 'k' => 1 } })
    expect(result.keys).to eq(%w[b a])
    expect(result['b'].keys).to eq(%w[z a])
  end
end

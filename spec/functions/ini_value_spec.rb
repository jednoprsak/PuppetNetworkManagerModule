# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager::ini_value' do
  it { is_expected.to run.with_params(nil).and_return('') }
  it { is_expected.to run.with_params('').and_return('') }
  it { is_expected.to run.with_params('eth0').and_return('eth0') }
  it { is_expected.to run.with_params(true).and_return('true') }
  it { is_expected.to run.with_params(false).and_return('false') }
  it { is_expected.to run.with_params(5).and_return('5') }
  it { is_expected.to run.with_params('with space inside').and_return('with space inside') }
  it { is_expected.to run.with_params('"kept as is"').and_return('"kept as is"') }
  it { is_expected.to run.with_params('8.8.8.8;').and_return('8.8.8.8;') }

  it { is_expected.to run.with_params('a\\b').and_return('a\\\\b') }
  it { is_expected.to run.with_params("l1\nl2").and_return('l1\\nl2') }
  it { is_expected.to run.with_params("a\tb").and_return('a\\tb') }
  it { is_expected.to run.with_params("a\rb").and_return('a\\rb') }
  it { is_expected.to run.with_params('  x').and_return('\\s x') }
  it { is_expected.to run.with_params('x  ').and_return('x \\s') }

  it { is_expected.to run.with_params(%w[a b]).and_return('a;b;') }
  it { is_expected.to run.with_params(['a;b', 'c']).and_return('a\;b;c;') }
  it { is_expected.to run.with_params(['a', 1, true]).and_return('a;1;true;') }
  it { is_expected.to run.with_params([]).and_return('') }
  it { is_expected.to run.with_params({ 'a' => 1 }).and_raise_error(ArgumentError) }
end

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

puppet_version = ENV.fetch('PUPPET_GEM_VERSION', '')
openvox_version = ENV.fetch('OPENVOX_GEM_VERSION', '')
legacy = puppet_version.match?(%r{\b6\b})

group :test do
  gem 'facterdb', require: false
  gem 'metadata-json-lint', require: false
  if !openvox_version.empty?
    gem 'openvox', openvox_version, require: false
  elsif !puppet_version.empty?
    gem 'puppet', puppet_version, require: false
  else
    gem 'puppet', require: false
  end
  gem 'puppet-lint', require: false
  gem 'puppet-syntax', require: false
  gem 'puppetlabs_spec_helper', legacy ? '~> 5.0' : ['>= 7.0', '< 9'], require: false
  gem 'racc', require: false
  gem 'rake', require: false
  gem 'rspec-puppet', legacy ? '~> 2.9' : '>= 4.0', require: false
  gem 'rspec-puppet-facts', require: false
  gem 'voxpupuli-puppet-lint-plugins', '>= 3.0', require: false
end

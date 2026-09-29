# frozen_string_literal: true

require 'json'

# Facts are generated from operatingsystem_support in metadata.json instead of
# facterdb, so every supported OS release is tested regardless of which
# releases the installed facterdb version happens to know.
NM_OS_FAMILY = {
  'Archlinux' => 'Archlinux',
  'Debian' => 'Debian',
  'Gentoo' => 'Gentoo',
  'Manjaro' => 'Archlinux',
  'Ubuntu' => 'Debian',
}.tap { |h| h.default = 'RedHat' }.freeze

NM_VERSION = { 'major' => '1', 'minor' => '40' }.freeze

# Builds a facts hash for the given OS and NetworkManager version.
def nm_test_facts(name, release, family = NM_OS_FAMILY[name], nm_version = NM_VERSION)
  {
    'kernel' => 'Linux',
    'os' => {
      'family' => family,
      'name' => name,
      'release' => { 'major' => release, 'full' => release },
    },
    'networking' => { 'hostname' => 'testhost', 'fqdn' => 'testhost.example.com' },
    'networkmanager' => { 'version' => nm_version },
  }
end

# Yields a label and the facts hash for every OS release listed in metadata.json.
def each_test_os
  metadata = JSON.parse(File.read(File.expand_path('../metadata.json', __dir__)))
  metadata['operatingsystem_support'].each do |entry|
    # rolling release systems have no release listed in metadata.json
    entry.fetch('operatingsystemrelease', ['rolling']).each do |release|
      yield "#{entry['operatingsystem']} #{release}", nm_test_facts(entry['operatingsystem'], release)
    end
  end
end

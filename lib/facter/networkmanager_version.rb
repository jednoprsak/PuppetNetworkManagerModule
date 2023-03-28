Facter.add(:networkmanager) do
  confine :kernel => 'Linux'
  version_s = [ 'major', 'minor', 'build' ]
  patch_s = [ 'patch', 'suffix' ]
  nm = Facter::Util::Resolution.which('NetworkManager')
  if nm.nil?
    Facter.debug("NetwormManager binary not found")
    next nil
  end
  output = Facter::Util::Resolution.exec("#{nm} --version")
  if output.nil?
    Facter.debug("'#{nm} --version' returned no output")
    next nil
  end
  output = output.strip
  nm_v = {'version' => { 'full' => output }}
  output = output.split('-', 2)
  version = output[0].split('.')
  if output.length() > 1
    patch = output[1].split('.', 2)
    (0..(patch.length()-1)).each {|i|
      nm_v['version'][patch_s[i]] = patch[i]
    }
  end
  (0..(version.length()-1)).each {|j|
    nm_v['version'][version_s[j]] = version[j]
  }
  setcode do
    nm_v
  end
end

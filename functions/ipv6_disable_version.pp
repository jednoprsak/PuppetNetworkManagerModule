# Ensures that the 'ignore' is returned when the 'disable' keyword is used on the NetworkManager version < 1.20
# Parameters:
#   $ipv6_method = IPv6 IP method of the interface

function networkmanager::ipv6_disable_version(
  Enum['auto', 'dhcp', 'manual', 'ignore', 'link-local', 'disabled'] $ipv6_method,
) >> String {
  # the fact is not there before NetworkManager is installed, then the version is not known to be old
  $major = $facts.dig('networkmanager', 'version', 'major')
  $minor = $facts.dig('networkmanager', 'version', 'minor')
  $legacy = $major =~ NotUndef and $minor =~ NotUndef and 1 == Integer($major) and 20 > Integer($minor)

  if 'disabled' == $ipv6_method and $legacy {
    include networkmanager::notify_ipv6_disabled
    $return = 'ignore'
  }
  else {
    $return = $ipv6_method
  }
  $return
}

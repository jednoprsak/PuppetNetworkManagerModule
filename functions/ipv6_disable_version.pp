# Ensures that the 'ignore' is returned when the 'disable' keyword is used on the networkamanger version < 1.20
# Parametres:
#   $ipv6_method = IPv6 IP method of the interface

function networkmanager::ipv6_disable_version(
  Enum['auto', 'dhcp', 'manual', 'ignore', 'link-local', 'disabled'] $ipv6_method,
) >> String {
  if (
    $ipv6_method == 'disabled'
      and
    Integer($facts['networkmanager']['version']['major']) == 1
      and
    Integer($facts['networkmanager']['version']['minor']) < 20
  )
  {
    include networkmanager::notify_ipv6_disabled
    $return = 'ignore'
  }
  else {
    $return = $ipv6_method
  }
  $return
}

# Returns the IPv6 DHCP DUID to write to the keyfile of the connection, undef when nothing should be written.
# The DUID is written only for the 'auto' and 'dhcp' methods of an active connection. The DUID of the connection wins,
# the $networkmanager::ipv6_dhcp_duid_default is used when it is not set. The 'auto' DUID needs the mac address.
# Parameters:
#   $duid = the DUID set for the connection (undef to use the default of the networkmanager class)
#   $mac_address = the mac address of the interface for the connection
#   $ipv6_method = the IPv6 method of the connection (after networkmanager::ipv6_disable_version)
#   $ensure = the state of the connection config
#   $state = the state of the connection (up/down)
#   $id = the id of the connection (for the error message)

function networkmanager::resolve_ipv6_duid(
  Optional[Networkmanager::DHCP_DUID] $duid,
  Optional[Stdlib::MAC]               $mac_address,
  String                              $ipv6_method,
  String                              $ensure,
  String                              $state,
  String                              $id,
) >> Optional[String] {
  if $ipv6_method in ['auto', 'dhcp'] and 'up' == $state and 'present' == $ensure {
    $effective = $duid ? {
      undef   => $networkmanager::ipv6_dhcp_duid_default,
      default => $duid,
    }
    case $effective {
      'unset': { undef }
      'auto':  {
        if $mac_address {
          networkmanager::get_ipv6_duid('auto', $mac_address)
        }
        else {
          fail("The IPv6 DHCP DUID of the connection '${id}' is 'auto' but no mac_address was supplied, set the mac_address, an ipv6_dhcp_duid ('unset' to use the NetworkManager default) or networkmanager::ipv6_dhcp_duid_default")
        }
      }
      default: { $effective }
    }
  }
  else {
    undef
  }
}

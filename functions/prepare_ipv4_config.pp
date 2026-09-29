# Prepares the "ipv4" section of the keyfile. Only the method is written when the IPv4 is disabled,
# the other settings would have no effect. Based on the idea of the pull request 24 by kbucheli.
# Parameters:
#   $ipv4_method = what method to use to get an IPv4 address
#   $ipv4_address = the IPv4 address(es) to assign to the interface, see networkmanager::address_settings
#   $ipv4_gateway = the IPv4 gateway for the connection
#   $ipv4_dns = the dns servers for the interface (array or semicolon separated string)
#   $ipv4_may_fail = is it OK that the IPv4 config fails?

function networkmanager::prepare_ipv4_config(
  Enum['auto', 'dhcp', 'manual', 'disabled', 'link-local'] $ipv4_method,
  Optional[Networkmanager::IPV4_ADDRESSES]                 $ipv4_address,
  Optional[Stdlib::IP::Address::V4::Nosubnet]              $ipv4_gateway,
  Optional[Networkmanager::DNS_IPV4]                       $ipv4_dns,
  Boolean                                                  $ipv4_may_fail,
) >> Hash {
  $details = $ipv4_method ? {
    'disabled' => {},
    default    => {
      'may-fail' => $ipv4_may_fail,
      'gateway'  => $ipv4_gateway,
    } + networkmanager::address_settings($ipv4_address) + {
      'dns'      => networkmanager::dns_list($ipv4_dns),
    },
  }
  networkmanager::compact_keyfile({ 'ipv4' => { 'method' => $ipv4_method } + $details })
}

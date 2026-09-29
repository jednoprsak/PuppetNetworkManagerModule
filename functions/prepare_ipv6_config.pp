# Prepares the "ipv6" section of the keyfile. Only the method is written when the IPv6 is ignored or disabled,
# the other settings would have no effect. Based on the idea of the pull request 24 by kbucheli.
# Parameters:
#   $ipv6_method = what method to use to get an IPv6 address (already adjusted by networkmanager::ipv6_disable_version)
#   $ipv6_address = the IPv6 address(es) to assign to the interface, see networkmanager::address_settings
#   $ipv6_gateway = the IPv6 gateway for the connection
#   $ipv6_dns = the dns servers for the interface (array or semicolon separated string)
#   $ipv6_addr_gen_mode = IPv6 method for generating of automatic interface address
#   $ipv6_privacy = should be the generated automatic address more private
#   $ipv6_may_fail = is it OK that the IPv6 config fails?
#   $ipv6_dhcp_duid = the IPv6 DHCP DUID, undef when it should not be written

function networkmanager::prepare_ipv6_config(
  Enum['auto', 'dhcp', 'manual', 'ignore', 'link-local', 'disabled'] $ipv6_method,
  Optional[Networkmanager::IPV6_ADDRESSES]                           $ipv6_address,
  Optional[Stdlib::IP::Address::V6::Nosubnet]                        $ipv6_gateway,
  Optional[Networkmanager::DNS_IPV6]                                 $ipv6_dns,
  Integer[0, 3]                                                      $ipv6_addr_gen_mode,
  Integer[-1, 2]                                                     $ipv6_privacy,
  Boolean                                                            $ipv6_may_fail,
  Optional[String]                                                   $ipv6_dhcp_duid,
) >> Hash {
  $details = $ipv6_method ? {
    /^(ignore|disabled)$/ => {},
    default               => {
      'addr-gen-mode' => $ipv6_addr_gen_mode,
      'ip6-privacy'   => $ipv6_privacy,
      'may-fail'      => $ipv6_may_fail,
      'gateway'       => $ipv6_gateway,
    } + networkmanager::address_settings($ipv6_address) + {
      'dns'           => networkmanager::dns_list($ipv6_dns),
      'dhcp-duid'     => $ipv6_dhcp_duid,
    },
  }
  networkmanager::compact_keyfile({ 'ipv6' => { 'method' => $ipv6_method } + $details })
}

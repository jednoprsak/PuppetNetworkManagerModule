# Prepares the "ipv4" configuration section
# Parametres:
#   $ipv4_method = what method to use to get an IPv4 address
#   $ipv4_address = semicolon separated list of the IPv4 addresses to assign to the interface in format 127.0.0.1/8
#   $ipv4_gateway = the IPv4 gateway for the connection
#   $ipv4_dns = semicolon seperated list of the dns servers for the interface
#   $ipv4_may_fail = is it ok that the IPv4 config fails?

function networkmanager::prepare_ipv4_config (
  Enum['auto', 'dhcp', 'manual', 'disabled', 'link-local'] $ipv4_method,
  Optional[Networkmanager::IPV4_CIDR]                      $ipv4_address,
  Optional[Stdlib::IP::Address::V4::Nosubnet]              $ipv4_gateway,
  Optional[Networkmanager::DNS_IPV4]                       $ipv4_dns,
  Boolean                                                  $ipv4_may_fail,
) >> Hash {

  $ipv4_base_config = { ipv4 => { method => $ipv4_method } }

  if $ipv4_method != 'disabled' {
    $ipv4_may_fail_config = { ipv4 => { may-fail => $ipv4_may_fail } }

    $ipv4_gw_config = $ipv4_gateway ? {
      undef   => {},
      default => { ipv4 => { gateway => $ipv4_gateway } },
    }

    $ipv4_address_config = $ipv4_address ? {
      undef   => {},
      default => { ipv4 => { address  => $ipv4_address } },
    }

    $ipv4_dns_config = $ipv4_dns ? {
      undef   => {},
      default => { ipv4 => { dns  => $ipv4_dns } },
    }

    $ipv4_detail_config = deep_merge(
        $ipv4_may_fail_config,
        $ipv4_gw_config,
        $ipv4_address_config,
        $ipv4_dns_config,
      )
  }
  else {
    $ipv4_detail_config = {}
  }

  deep_merge($ipv4_base_config, $ipv4_detail_config)
}

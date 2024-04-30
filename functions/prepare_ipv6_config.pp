# Prepares the "ipv6" configuration section
# Parametres:
#   $ipv6_method = what method to use to get an ipv6 address
#   $ipv6_address = semicolon separated list of the ipv6 addresses to assign to the interface in format aa::bb:cc/64
#   $ipv6_gateway = the ipv6 gateway for the connection
#   $ipv6_dns = semicolon seperated list of the dns servers for the interface
#   $ipv6_addr_gen_mode = IPv6 method for generating of automatic interface address
#   $ipv6_privacy = should be the generated automatic address more private
#   $ipv6_may_fail = is it ok that the ipv6 config fails?
#   $ipv6_dhcp_duid = IPv6 DHCP DUID 'auto' value generates it with module from mac of the interface
#   $mac_address = the mac of the interface for the connection

function networkmanager::prepare_ipv6_config (
  Enum['auto','dhcp','manual','ignore','link-local','disabled'] $ipv6_method,
  Optional[Stdlib::IP::Address::V6::CIDR]                       $ipv6_address,
  Optional[Stdlib::IP::Address::V6::Nosubnet]                   $ipv6_gateway,
  Optional[Networkmanager::DNS_IPV6]                            $ipv6_dns,
  Integer[0, 3]                                                 $ipv6_addr_gen_mode,
  Integer[-1, 2]                                                $ipv6_privacy,
  Boolean                                                       $ipv6_may_fail,
  Optional[String]                                              $ipv6_dhcp_duid,
  Optional[Stdlib::MAC]                                         $mac_address,
) >> Hash {

  $ipv6_method_w = networkmanager::ipv6_disable_version($ipv6_method)

  if $ipv6_method_w in ['ignore', 'disabled'] {
    $ipv6_base_config = {
      ipv6 => {
        method => $ipv6_method_w,
      }
    }
    $ipv6_detail_config = {}
  }
  else {
    $ipv6_base_config = {
      ipv6 => {
        method        => $ipv6_method_w,
        addr-gen-mode => $ipv6_addr_gen_mode,
        ip6-privacy   => $ipv6_privacy,
        may-fail      => $ipv6_may_fail,
      }
    }

    $ipv6_gw_config = $ipv6_gateway ? {
      undef   => {},
      default => { ipv6 => { gateway => $ipv6_gateway } },
    }

    $ipv6_address_config = $ipv6_address ? {
      undef   => {},
      default => { ipv6 => { address  => $ipv6_address } },
    }

    $ipv6_dns_config = $ipv6_dns ? {
      undef   => {},
      default => { ipv6 => { dns  => $ipv6_dns } },
    }

    $ipv6_dhcp_duid_w = networkmanager::get_ipv6_duid($ipv6_dhcp_duid, $mac_address)

    if $ipv6_dhcp_duid_w == undef
      and $ipv6_method_w in ['auto', 'dhcp']
      and 'present' == $ensure
      and 'up' == $state {
        fail("IPv6 method for connection '${id}' is '${ipv6_method_w}' but no \$ipv6_dhcp_duid was supplied.")
    }
    elsif $ipv6_method_w in ['auto', 'dhcp'] and 'up' == $state {
      $ipv6_duid_config = {
        ipv6 => {
          dhcp-duid => $ipv6_dhcp_duid_w,
        }
      }
    }
    else {
      $ipv6_duid_config = {}
    }

    $ipv6_detail_config = deep_merge(
        $ipv6_gw_config,
        $ipv6_address_config,
        $ipv6_dns_config,
        $ipv6_duid_config
      )
  }

  deep_merge($ipv6_base_config, $ipv6_detail_config)
}

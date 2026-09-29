# This defined resource creates the connection keyfile.
# Parameters:
#   $ensure = state of the interface config DEFAULT: present
#   $state = state of the interface (UP/DOWN) not relevant when $ensure == 'absent' DEFAULT: 'up'
#   $id = the name of the connection DEFAULT: $title of the resource
#   $interface_name = name of the connection interface REQUIRED DEFAULT: $title of the resource
#   $mac_address = the mac of the interface for the connection
#   $master = $id or UUID of the connection master if applicable
#   $type = the type of the connection DEFAULT: 'ethernet'
#   $ipv4_method = what method to use to get an IPv4 address DEFAULT: 'auto'
#   $ipv4_address = the IPv4 address with the prefix length and an optional gateway (192.168.1.12/24 or 192.168.1.12/24,192.168.1.1), more addresses as an array or as a string separated by a semicolon (192.168.1.12/24;192.168.2.12/24)
#   $ipv4_gateway = the IPv4 gateway for the connection
#   $ipv4_dns = up to 5 DNS servers for the IPv4: an array of addresses or a string with the addresses separated by a semicolon (8.8.8.8;8.8.4.4;)
#   $ipv4_may_fail = is it OK that the IPv4 config fails? DEFAULT: true
#   $ipv6_method = what method to use to get an ipv6 address DEFAULT: 'auto'
#   $ipv6_address = the IPv6 address with the prefix length (aa::bb:cc/64), more addresses as an array or as a string separated by a semicolon (aa::bb:cc/64;dd::ee:ff/64)
#   $ipv6_gateway = the ipv6 gateway for the connection
#   $ipv6_dns = up to 5 DNS servers for the IPv6: an array of addresses or a string with the addresses separated by a semicolon (aa::bb;cc::dd;)
#   $ipv6_dhcp_duid = IPv6 DHCP DUID 'auto' value generates it with module from mac of the interface
#   $ipv6_addr_gen_mode = IPv6 method for generating of automatic interface address
#   $ipv6_privacy = should be the generated automatic address more private
#   $ipv6_may_fail = is it OK that the ipv6 config fails? DEFAULT: true
#   $additional_config = Other not covered configuration
#     In the case when you want to specify special not listed parameters you can add them through
#     $additional_config hash and it will be merged with other parameters.
#     The additional_config has the HIGHEST priority when merged!
#     ie: it will override the defined values of the connection in case of the conflict

define networkmanager::ifc::connection (
  Enum['absent', 'present']                                          $ensure = present,
  Enum['up', 'down']                                                 $state = 'up',
  String                                                             $id = $title,
  Optional[String[3, 15]]                                            $interface_name = undef,
  Optional[Stdlib::MAC]                                              $mac_address = undef,
  Optional[String]                                                   $master = undef,
  String                                                             $type = 'ethernet',
  Enum['auto', 'dhcp', 'manual', 'disabled', 'link-local']           $ipv4_method = 'auto',
  Optional[Networkmanager::IPV4_ADDRESSES]                                $ipv4_address = undef,
  Optional[Networkmanager::DNS_IPV4]                                 $ipv4_dns = undef,
  Boolean                                                            $ipv4_may_fail = true,
  Optional[Stdlib::IP::Address::V4::Nosubnet]                        $ipv4_gateway = undef,
  Enum['auto', 'dhcp', 'manual', 'ignore', 'link-local', 'disabled'] $ipv6_method = 'auto',
  Optional[Networkmanager::IPV6_ADDRESSES]                            $ipv6_address = undef,
  Optional[Stdlib::IP::Address::V6::Nosubnet]                        $ipv6_gateway = undef,
  Optional[Networkmanager::DNS_IPV6]                                 $ipv6_dns = undef,
  Optional[String]                                                   $ipv6_dhcp_duid = undef,
  Integer[0, 3]                                                      $ipv6_addr_gen_mode = 0,
  Integer[-1, 2]                                                     $ipv6_privacy = 0,
  Boolean                                                            $ipv6_may_fail = true,
  Hash                                                               $additional_config = {},
) {
  include networkmanager
  Class['networkmanager'] -> Networkmanager::Ifc::Connection[$title]
  if $id !~ String[3, $networkmanager::max_length_of_connection_id] {
    fail("The connection \$id must have length from 3 to ${networkmanager::max_length_of_connection_id} characters")
  }

  if $type == 'ethernet' and $interface_name == undef and $mac_address == undef {
    fail("For ethernet connection ${id} either interface_name or mac_address is required")
  }

  $uuid = networkmanager::connection_uuid($id)

  $ipv6_method_w = networkmanager::ipv6_disable_version($ipv6_method)

  $ipv6_dhcp_duid_w = networkmanager::get_ipv6_duid($ipv6_dhcp_duid, $mac_address)

  if $ipv6_method_w in ['auto', 'dhcp'] and 'up' == $state {
    if $ipv6_dhcp_duid_w == undef and 'present' == $ensure {
      fail("IPv6 method for connection '${id}' is '${ipv6_method_w}' but no \$ipv6_dhcp_duid was supplied.")
    }
    $ipv6_duid = $ipv6_dhcp_duid_w
  }
  else {
    $ipv6_duid = undef
  }

  $keyfile_contents = deep_merge(
    networkmanager::compact_keyfile({
      'connection' => {
        'interface-name' => $interface_name,
        'master'         => $master ? { undef => undef, default => networkmanager::connection_uuid($master) },
        'id'             => $id,
        'uuid'           => $uuid,
        'type'           => $type,
      },
      'ethernet'   => { 'mac-address' => $mac_address },
    }),
    networkmanager::prepare_ipv4_config($ipv4_method, $ipv4_address, $ipv4_gateway, $ipv4_dns, $ipv4_may_fail),
    networkmanager::prepare_ipv6_config(
      $ipv6_method_w,
      $ipv6_address,
      $ipv6_gateway,
      $ipv6_dns,
      $ipv6_addr_gen_mode,
      $ipv6_privacy,
      $ipv6_may_fail,
      $ipv6_duid
    ),
    $additional_config
  )

  networkmanager::connection_keyfile_manage {
    $id:
      ensure  => $ensure,
      content => $keyfile_contents;
  }

  if $ensure == present {
    networkmanager::activate_connection($uuid, $id, $state)

    # NetworkManager leaves the link administratively UP after the connection is deactivated
    # (or when it was never activated), so shut the link down explicitly. Bringing it back
    # is done by switching $state to 'up' or manually with `nmcli connection up <id>`.
    if 'down' == $state and ($interface_name or $mac_address) {
      $link_device = $interface_name ? {
        undef   => "\$(basename \"\$(dirname \"\$(grep -il '^${mac_address}\$' /sys/class/net/*/address | head -n1)\")\")",
        default => $interface_name,
      }

      exec {
        "shutdown link of connection ${uuid}":
          command  => "ip link set dev ${link_device} down",
          onlyif   => "ip -o link show up dev ${link_device} | grep -q .",
          provider => 'shell',
          path     => ['/usr/sbin', '/sbin', '/usr/bin', '/bin'],
          user     => 'root',
          group    => 'root';
      }
    }
  }

  include networkmanager::reload
  Networkmanager::Ifc::Connection[$title] ~> Class['networkmanager::reload']
}

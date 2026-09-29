# This defined resource creates master bond keyfile.
#
# @param ensure
#   state of the interface config DEFAULT: present
# @param state
#   state of the interface (UP/DOWN) not relevant when $ensure == 'absent' DEFAULT: 'up'
# @param id
#   the name of the connection DEFAULT: $title of the resource
# @param interface_name
#   name of the connection interface DEFAULT: $title of the resource
# @param mac_address
#   the mac of the interface for the connection
# @param master
#   $id or UUID of the connection master if applicable
# @param bond_mode
#   bonding mode DEFAULT: 'balance-rr'
# @param ipv4_method
#   what method to use to get an IPv4 address DEFAULT: 'auto'
# @param ipv4_address
#   the IPv4 address with the prefix length and an optional gateway (192.0.2.12/24 or 192.0.2.12/24,192.0.2.1), more addresses as an array or as a string separated by a semicolon (192.0.2.12/24;198.51.100.12/24)
# @param ipv4_gateway
#   the IPv4 gateway for the connection
# @param ipv4_dns
#   up to 5 DNS servers for the IPv4: an array of addresses or a string with the addresses separated by a semicolon (192.0.2.53;192.0.2.54;)
# @param ipv4_may_fail
#   is it OK that the IPv4 config fails? DEFAULT: true
# @param ipv6_method
#   what method to use to get an ipv6 address DEFAULT: 'auto'
# @param ipv6_address
#   the IPv6 address with the prefix length (2001:db8::12/64), more addresses as an array or as a string separated by a semicolon (2001:db8::12/64;2001:db8:1::12/64)
# @param ipv6_gateway
#   the ipv6 gateway for the connection
# @param ipv6_dns
#   up to 5 DNS servers for the IPv6: an array of addresses or a string with the addresses separated by a semicolon (2001:db8::53;2001:db8::54;)
# @param ipv6_dhcp_duid
#   IPv6 DHCP DUID, 'auto' builds it from the $mac_address, 'unset' writes nothing (NetworkManager default), a NetworkManager keyword or a literal DUID is used as it is DEFAULT: $networkmanager::ipv6_dhcp_duid_default
# @param ipv6_addr_gen_mode
#   IPv6 method for generating of automatic interface address
# @param ipv6_privacy
#   should be the generated automatic address more private
# @param ipv6_may_fail
#   is it OK that the ipv6 config fails? DEFAULT: true
# @param additional_config
#   Other not covered configuration
#   In the case when you want to specify special not listed parameters you can add them through
#   $additional_config hash and it will be merged with other parameters.
#   The additional_config has the HIGHEST priority when merged!
#   ie: it will override the defined values of the connection in case of the conflict

define networkmanager::ifc::bond (
  Enum['absent', 'present']                                     $ensure = present,
  Enum['up', 'down']                                            $state = 'up',
  String                                                        $id = $title,
  String[3, 15]                                                 $interface_name = $title,
  Optional[Stdlib::MAC]                                         $mac_address = undef,
  Optional[String]                                              $master = undef,
  Variant[
    Integer[0, 6],
    Enum[
      'balance-rr',
      'active-backup',
      'balance-xor',
      'broadcast',
      '802.3ad',
      'balance-tlb',
      'balance-alb'
    ]
  ]                                                           $bond_mode = 'balance-rr',
  Enum['auto','dhcp','manual','disabled','link-local']          $ipv4_method = 'auto',
  Optional[Networkmanager::IPV4_ADDRESSES]                           $ipv4_address = undef,
  Optional[Stdlib::IP::Address::V4::Nosubnet]                   $ipv4_gateway = undef,
  Optional[Networkmanager::DNS_IPV4]                            $ipv4_dns = undef,
  Boolean                                                       $ipv4_may_fail = true,
  Enum['auto','dhcp','manual','ignore','link-local','disabled'] $ipv6_method = 'auto',
  Optional[Networkmanager::IPV6_ADDRESSES]                       $ipv6_address = undef,
  Optional[Stdlib::IP::Address::V6::Nosubnet]                   $ipv6_gateway = undef,
  Optional[Networkmanager::DNS_IPV6]                            $ipv6_dns = undef,
  Optional[Networkmanager::DHCP_DUID]                           $ipv6_dhcp_duid = undef,
  Integer[0, 3]                                                 $ipv6_addr_gen_mode = 0,
  Integer[-1, 2]                                                $ipv6_privacy = 0,
  Boolean                                                       $ipv6_may_fail = true,
  Hash                                                          $additional_config = {},
) {
  include networkmanager
  Class['networkmanager'] -> Networkmanager::Ifc::Bond[$title]

  $ipv6_method_w = networkmanager::ipv6_disable_version($ipv6_method)

  $uuid = networkmanager::connection_uuid($id)

  $ipv6_duid = networkmanager::resolve_ipv6_duid($ipv6_dhcp_duid, $mac_address, $ipv6_method_w, $ensure, $state, $id)

  $keyfile_contents = deep_merge(
    networkmanager::compact_keyfile({
      'connection' => {
        'master'         => $master ? { undef => undef, default => networkmanager::connection_uuid($master) },
        'id'             => $id,
        'uuid'           => $uuid,
        'type'           => 'bond',
        'interface-name' => $interface_name,
      },
      'bond'       => { 'mode' => $bond_mode },
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
  }

  include networkmanager::reload
  Networkmanager::Ifc::Bond[$title] ~> Class['networkmanager::reload']
}

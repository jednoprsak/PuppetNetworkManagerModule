# This defined resource creates master bond keyfile.
# Parametres:
#   $ensure = state of the interface config DEFAULT: present
#   $state = state of the interface (UP/DOWN) not relevant when $ensure == 'absent' DEFAULT: 'up'
#   $id = the name of the connection DEFAULT: $title of the resource
#   $interface_name = name of the connection interface REQUIRED DEFAULT: $title of the resource
#   $mac_address = the mac of the interface for the connection
#   $master = $id or UUID of the connection maste if applicable
#   $bond_mode = bonding mode DEFAULT: 'balance-rr'
#   $ipv4_method = what method to use to get an IPv4 address DEFAULT: 'auto'
#   $ipv4_address = semicolon separated list of the IPv4 addresses to assign to the interface in format 127.0.0.1/8
#   $ipv4_gateway = the IPv4 gateway for the connection
#   $ipv4_dns = semicolon seperated list of the dns servers for the interface
#   $ipv4_may_fail = is it ok that the IPv4 config fails? DEFAULT: true
#   $ipv6_method = what method to use to get an ipv6 address DEFAULT: 'auto'
#   $ipv6_address = semicolon separated list of the ipv6 addresses to assign to the interface in format aa::bb:cc/64
#   $ipv6_gateway = the ipv6 gateway for the connection
#   $ipv6_dns = semicolon seperated list of the dns servers for the interface
#   $ipv6_dhcp_duid = IPv6 DHCP DUID 'auto' value generates it with module from mac of the interface
#   $ipv6_addr_gen_mode = IPv6 method for generating of automatic interface address
#   $ipv6_privacy = should be the generated automatic address more private
#   $ipv6_may_fail = is it ok that the ipv6 config fails? DEFAULT: true
#   $addtional_config = Other not covered configuration
#     In the case when you want to specify special not listed parameters you can add them through
#     $additional_config hash and it will be merged with other parameters.
#     The additional_config has the HIGHEST priority when merged!
#     ie: it will override the defined values of the connection in case of the conflict

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
  Optional[Networkmanager::IPV4_CIDR]                           $ipv4_address = undef,
  Optional[Stdlib::IP::Address::V4::Nosubnet]                   $ipv4_gateway = undef,
  Optional[Networkmanager::DNS_IPV4]                            $ipv4_dns = undef,
  Boolean                                                       $ipv4_may_fail = true,
  Enum['auto','dhcp','manual','ignore','link-local','disabled'] $ipv6_method = 'auto',
  Optional[Stdlib::IP::Address::V6::CIDR]                       $ipv6_address = undef,
  Optional[Stdlib::IP::Address::V6::Nosubnet]                   $ipv6_gateway = undef,
  Optional[Networkmanager::DNS_IPV6]                            $ipv6_dns = undef,
  Variant[
      Pattern[/\h{2}(:\h{2})+$/],
      Undef,
      Enum[
          'auto',
          'lease',
          'll',
          'llt',
          'stable-ll',
          'stable-llt',
          'stable-uuid'
        ]
    ]                                                           $ipv6_dhcp_duid = undef,
  Integer[0, 3]                                                 $ipv6_addr_gen_mode = 0,
  Integer[-1, 2]                                                $ipv6_privacy = 0,
  Boolean                                                       $ipv6_may_fail = true,
  Hash                                                          $additional_config = {},
){
  include networkmanager
  Class['networkmanager'] -> Networkmanager::Ifc::Bond[$title]

  $uuid = networkmanager::connection_uuid($id)

  if $master {
    $master_config = { connection => { master  => networkmanager::connection_uuid($master), }, }
  }
  else {
    $master_config = {}
  }

  $connection_config = {
    connection => {
      id             => $id,
      uuid           => $uuid,
      type           => 'bond',
      interface-name => $interface_name,
    },
    bond => { mode => $bond_mode, }
  }

  $ipv4_config = networkmanager::prepare_ipv4_config(
      $ipv4_method,
      $ipv4_address,
      $ipv4_gateway,
      $ipv4_dns,
      $ipv4_may_fail
    )
  $ipv6_config = networkmanager::prepare_ipv6_config(
      $ipv6_method,
      $ipv6_address,
      $ipv6_gateway,
      $ipv6_dns,
      $ipv6_dhcp_duid,
      $ipv6_addr_gen_mode,
      $ipv6_privacy,
      $ipv6_may_fail
    )

  $keyfile_contents = deep_merge(
      $master_config,
      $connection_config,
      $ipv4_config,
      $ipv6_config,
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

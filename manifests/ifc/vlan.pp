# This defined resource creates the vlan connection keyfile.
# Parametres:
#   $vlan_id = id of the desired vlan REQUIRED
#   $vlan_parent = $id or UUID of the parent for this interface REQUIRED
#   $ensure = state of the interface config DEFAULT: present
#   $state = state of the interface (UP/DOWN) not relevant when $ensure == 'absent' DEFAULT: 'up'
#   $id = the name of the connection DEFAULT: $title of the resource
#   $interface_name = name of the connection interface REQUIRED DEFAULT: $title of the resource
#   $master = $id or UUID of the connection maste if applicable
#   $slave_type = type which this port should assume if set as slave (IGNORED if $master == undef)
#   $vlan_flags = flags for the 802.1Q vlan protocol DEFAULT: 1
#   $addtional_config = Other not covered configuration
#     In the case when you want to specify special not listed parameters you can add them through
#     $additional_config hash and it will be merged with other parameters.
#     The additional_config has the HIGHEST priority when merged!
#     ie: it will override the defined values of the connection in case of the conflict

define networkmanager::ifc::vlan (
  Integer[1, 4094]          $vlan_id,
  Optional[String]          $vlan_parent,
  Enum['absent', 'present'] $ensure = present,
  Enum['up', 'down']        $state = 'up',
  String                    $id = $title,
  String[3, 15]             $interface_name = $title,
  Optional[String]          $master = undef,
  String                    $slave_type  = 'bridge',
  Integer[0]                $vlan_flags = 1,
  Hash                      $additional_config = {},
) {
  include networkmanager
  Class['networkmanager'] -> Networkmanager::Ifc::Vlan[$title]

  if $id !~ String[3, $networkmanager::max_length_of_connection_id] {
    fail("The connection \$id must have length from 3 to ${networkmanager::max_length_of_connection_id} characters")
  }

  $uuid = networkmanager::connection_uuid($id)

  $master_config = $master ? {
    undef   => {},
    default => {
      connection => {
        master => networkmanager::connection_uuid($master),
        slave-type     => $slave_type,
      }
    },
  }

  $connection_config = {
    connection => {
      id             => $id,
      uuid           => $uuid,
      type           => 'vlan',
      interface-name => $interface_name,
    },
    vlan => {
      id     => $vlan_id,
      flags  => $vlan_flags,
      parent => networkmanager::connection_uuid($vlan_parent),
    },
  }

  $keyfile_contents = deep_merge($master_config, $connection_config, $additional_config)
  networkmanager::connection_keyfile_manage {
    $id:
      ensure  => $ensure,
      content => $keyfile_contents;
  }

  if $ensure == present {
    networkmanager::activate_connection($uuid, $id, $state)
  }

  include networkmanager::reload
  Networkmanager::Ifc::Vlan[$title] ~> Class['networkmanager::reload']
}

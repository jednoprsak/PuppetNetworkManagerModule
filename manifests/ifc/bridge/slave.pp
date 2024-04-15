# This defined resource creates bridge slave keyfile.
# Parametres:
#   $master = $id or UUID of the master interface uned which this slave should operate REQUIRED
#   $ensure = state of the interface config DEFAULT: present
#   $state = state of the interface (UP/DOWN) not relevant when $ensure == 'absent' DEFAULT: 'up'
#   $id = the name of the connection DEFAULT: $title of the resource
#   $type = connection type DEFAULT: ethernet
#   $mac_address = the mac of the interface for the connection REQUIRED IF $ifc_name was not supplied
#   $interface_name = name of the connection interface REQUIRED IF $mac_address was not supplied
#   $addtional_config = Other not covered configuration
#     In the case when you want to specify special not listed parameters you can add them through
#     $additional_config hash and it will be merged with other parameters.
#     The additional_config has the HIGHEST priority when merged!
#     ie: it will override the defined values of the connection in case of the conflict

define networkmanager::ifc::bridge::slave (
  String                    $master,
  Enum['absent', 'present'] $ensure = present,
  Enum['up', 'down']        $state = 'up',
  String                    $id = $title,
  String                    $type = 'ethernet',
  Optional[Stdlib::MAC]     $mac_address = undef,
  Optional[String[3, 15]]   $interface_name = undef,
  Hash                      $additional_config = {},
){
  include networkmanager
  Class['networkmanager'] -> Networkmanager::Ifc::Bridge::Slave[$title]

  if $id !~ String[3, $networkmanager::max_length_of_connection_id] {
    fail("The connection \$id must have length from 3 to ${networkmanager::max_length_of_connection_id} characters")
  }

  $uuid = networkmanager::connection_uuid($id)

  $int_mac_config = networkmanager::validate_ifc_name_and_mac(
      $name,
      $title,
      $mac_address,
      $interface_name
    )

  $connection_config = {
    connection => {
      id         => $id,
      uuid       => $uuid,
      type       => $type,
      master     => networkmanager::connection_uuid($master),
      slave-type => 'bridge',
    }
  }

  $keyfile_contents = deep_merge($int_mac_config, $connection_config, $additional_config)

  networkmanager::connection_keyfile_manage {
    $id:
      ensure  => $ensure,
      content => $keyfile_contents;
  }

  if $ensure == present {
    networkmanager::activate_connection($uuid, $id, $state)
  }

  include networkmanager::reload
  Networkmanager::Ifc::Bridge::Slave[$title] ~> Class['networkmanager::reload']
}

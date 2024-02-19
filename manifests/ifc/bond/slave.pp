# This defined resource creates bond slave keyfile.
# You can read parameters below.
# In the case when you want to specify special not listed parameters you can add them through additional_config hash and it will be merged with other parameters.
define networkmanager::ifc::bond::slave (
  Enum['absent', 'present'] $ensure = present,
  Enum['up', 'down']        $state = 'up',
  String                    $id = $title, #connection name used during the start via nmcli
  String                    $type = 'ethernet',
  String                    $master = undef,
  String                    $slave_type = 'bond',
  Stdlib::MAC               $mac_address = undef,
  Hash                      $additional_config = {}
) {
  include networkmanager
  Class['networkmanager'] -> Networkmanager::Ifc::Bond::Slave[$title]

  $connection_config = {
    connection => {
      id             => $id,
      uuid => networkmanager::connection_uuid($id),
      type           => $type,
      master         => $master,
      slave-type     => $slave_type
    },
    ethernet => {
      mac-address => $mac_address
    }
  }

  $keyfile_contents = deep_merge($connection_config, $additional_config)
  $keyfile_settings = {
    'path'              => "/etc/NetworkManager/system-connections/${id}.nmconnection",
    'quote_char'        => '',
    'key_val_separator' => '=',
    'require'           => File["/etc/NetworkManager/system-connections/${id}.nmconnection"]
  }

  file {
     "/etc/NetworkManager/system-connections/${id}.nmconnection":
     ensure  => $ensure,
     owner   => 'root',
     group   => 'root',
     replace => true,
     mode    => '0600',
     content => hash2ini($keyfile_contents,$keyfile_settings);
  }

  if $ensure == present {

#  @@exec { "activate ${id}":
#     command => networkmanager::reload_connection($id, $state),
#     provider    => 'shell',
#     group => 'root',
#     user => 'root',
#     subscribe => File["/etc/NetworkManager/system-connections/${id}.nmconnection"],
#     refreshonly => true,
#     tag => "nmactivate-2022b07${networkmanager::sys_id}";
#  }

   networkmanager::activate_connection($id, $state)

  }

  include networkmanager::reload
  Networkmanager::Ifc::Bond::Slave[$title] ~> Class['networkmanager::reload']
}

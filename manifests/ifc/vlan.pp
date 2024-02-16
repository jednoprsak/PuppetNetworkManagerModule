# This defined resource creates vlan keyfile.
# You can read parameters below.
# In the case when you want to specify special not listed parameters you can add them through additional_config hash and it will be merged with other parameters.
define networkmanager::ifc::vlan (
  Enum['absent', 'present'] $ensure = present,
  String                    $id = $title, #connection name used during the start via nmcli
  String                    $type = 'vlan',
  Enum['up', 'down']        $state = 'up',
  Optional[String]          $master = undef,
  String                    $slave_type  = 'bridge',
  String                    $vlan_id = undef,
                            $vlan_flags = 1,
  String                    $vlan_parent = undef,
  Hash                      $additional_config = {}
) {
  include networkmanager
  Class['networkmanager'] -> Networkmanager::Ifc::Vlan[$title]

  if $master {
    $connection_config = {
      connection => {
        id => $id,
        uuid => networkmanager::connection_uuid($id),
        type => $type,
        interface-name => $id,
        slave-type => $slave_type,
        master => $master,
      },
      vlan => {
        id => $vlan_id,
        flags => $vlan_flags,
        parent => $vlan_parent,
      },
    }
  }
  elsif !$master {
    $connection_config = {
      connection => {
        id => $id,
        uuid => networkmanager::connection_uuid($id),
        type => $type,
        interface-name => $id,
      },
      vlan => {
        id => $vlan_id,
        flags => $vlan_flags,
        parent => $vlan_parent,
      },
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
  Networkmanager::Ifc::Vlan[$title] ~> Class['networkmanager::reload']
}

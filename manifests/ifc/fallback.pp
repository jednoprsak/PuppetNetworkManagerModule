# This defined resource creates user defined keyfile
define networkmanager::ifc::fallback(
  Enum['absent', 'present'] $ensure = present,
  Enum['up', 'down']        $state = 'up',
  String[3, 15]             $id = $title,
  Hash                      $config = {}, #pozaduje tento hash
) {
  include networkmanager
  Networkmanager::Ifc::Fallback[$title] ~> Class['networkmanager']
  File['/etc/NetworkManager/NetworkManager.conf'] -> Networkmanager::Ifc::Fallback[$title]


  $confilename = "/etc/NetworkManager/system-connections/${id}.nmconnection"
  $uuid = networkmanager::connection_uuid($id)

  $ensure_file = $ensure ? {
    'absent'  => 'absent',
    'present' => 'file',
    default   => 'file'
  }

  $needed_params = {
    'connection' => {
      'id'          => $id,
      'uuid'        => $uuid,
      'type'        => 'ethernet',
    },
    'ethernet'   => {
      'auto-negotiate' => 'true',
    },
    'ipv4'       => {
      'method' => 'auto',
    },
    'ipv6'       => {
      'method' => 'auto',
    }
  }


  # Translates indentificatos to UUID
  # parent => 'bond0'
  # becames
  # parent=58d7fc42-8392-4ab9-924d-ab39f6f2434b
  $non_uuid_parents = keys($config).filter |$p|{
    'parent' in keys($config[$p]) and $config[$p]['parent'] !~ /^\h{8}(-\h{4}){3}-\h{12}$/
  }.reduce({}) |$nup, $px| {
    $nup + {$px => {'parent' => networkmanager::connection_uuid($config[$px]['parent'])}}
  }
  $non_uuid_masters = keys($config).filter |$m|{
    'master' in keys($config[$m]) and $config[$m]['master'] !~ /^\h{8}(-\h{4}){3}-\h{12}$/
  }.reduce({}) |$num, $mx| {
    $num + {$mx => {'master' => networkmanager::connection_uuid($config[$mx]['master'])}}
  }


  $params_e = deep_merge($needed_params, $config, $non_uuid_parents, $non_uuid_masters)

  $keyfile_settings = {
    'path'              => $confilename,
    'quote_char'        => '',
    'key_val_separator' => '=',
    'require'           => File[$confilename],
  }

  file {
    $confilename:
      ensure  => $ensure_file,
      owner   => 'root',
      group   => 'root',
      replace => true,
      backup  => false,
      mode    => '0600',
      content => hash2ini($params_e,$keyfile_settings);
  }

  if $ensure == present {
    networkmanager::activate_connection($id, $state)
  }

  include networkmanager::reload
  Networkmanager::Ifc::Fallback[$title] ~> Class['networkmanager::reload']
}


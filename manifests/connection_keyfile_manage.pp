# This defined resource manages the connection keyfiles
# It should not be used by user
define networkmanager::connection_keyfile_manage (
  Hash                      $content,
  Enum['absent', 'present'] $ensure = present,

){
  $ensure_file = $ensure ? {
    'present' => file,
    default   => absent,
  }
  $keyfile_settings = {
    'path'              => "/etc/NetworkManager/system-connections/${title}.nmconnection",
    'quote_char'        => '',
    'key_val_separator' => '=',
    'require'           => File["/etc/NetworkManager/system-connections/${title}.nmconnection"],
  }

  file {
    "/etc/NetworkManager/system-connections/${title}.nmconnection":
      ensure  => $ensure_file,
      owner   => 'root',
      group   => 'root',
      replace => true,
      mode    => '0600',
      content => hash2ini($content, $keyfile_settings);
  }
}

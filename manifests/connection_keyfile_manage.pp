# This defined resource manages the connection keyfiles
# It should not be used by user
define networkmanager::connection_keyfile_manage (
  Hash                      $content,
  Enum['absent', 'present'] $ensure = present,

) {
  $ensure_file = $ensure ? {
    'present' => file,
    default   => absent,
  }
  file {
    "/etc/NetworkManager/system-connections/${title}.nmconnection":
      ensure  => $ensure_file,
      owner   => 'root',
      group   => 'root',
      replace => true,
      mode    => '0600',
      content => epp('networkmanager/ini.epp', { 'content' => $content });
  }
}

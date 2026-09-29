# This defined resource manages the connection keyfiles
# It should not be used by user
#
# @param content
#   The keyfile as a hash of the sections, each section is a hash of the settings (rendered by the templates/ini.epp)
# @param ensure
#   state of the interface config DEFAULT: present
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

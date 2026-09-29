# This class manages NetworkManager services
# Not to be used by user
#
# @param wait_online
#   Taken from `$networkmanager::wait_online`

class networkmanager::service (
  Boolean $wait_online = $networkmanager::wait_online,
) {
  if $wait_online {
    $wait_ensure = running
    $wait_enable = true
  }
  else {
    $wait_ensure = stopped
    $wait_enable = false
  }
  service {
    'NetworkManager-wait-online.service':
      ensure => $wait_ensure,
      enable => $wait_enable;
    'NetworkManager.service':
      ensure => running,
      enable => true;
  }
}

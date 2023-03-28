# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# This class applies NetworkManager service resource.
#
class networkmanager::service (
  Boolean $wait_online = $networkmanager::wait_online,
){
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

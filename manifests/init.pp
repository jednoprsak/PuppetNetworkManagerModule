# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# This is main class of the network manager puppet module and 
# you can define here nm module behaviour setting up parameters:
#   $erase_unmanaged_keyfiles - true/false - If you want to remove puppet unmanaged keyfiles from /etc/NetworkManager/system-connections/ directory
#   $no_auto_default -          true/false - If you want to add no_auto_defaut=* option inside main /etc/NetworkManager/NetworkManager.conf config file.
#   $install_package -          true/false - If you want to install puppet package from puppet module
#   $version         -          string     - version string for NetworkManager version you want to install
# @example
#   include networkmanager
# 
class networkmanager (
  Boolean $erase_unmanaged_keyfiles = false,
  Boolean $no_auto_default = false,
  Boolean $install_package = true,
  Optional[String] $version = undef,
  Array[String] $unmanaged_devices = [],
  Boolean $wait_online = true,
  Variant[Boolean, Enum['stub'], Undef] $use_internal_resolv_conf = undef,
  Array[String] $plugins = ['keyfile'],
)
{
  $sys_id = [
    $trusted['certname'],
    $facts['certname'],
    $facts['clientcert'],
    $facts['hostname'],
  ].filter |$hn| { $hn =~ String[1] }[0]
  include networkmanager::os

  include networkmanager::install

  include networkmanager::config

  include networkmanager::service

  Class['networkmanager::os']
  -> Class['networkmanager::install']
  -> Class['networkmanager::config']
  -> Class['networkmanager::service']
}

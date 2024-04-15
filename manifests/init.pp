# This is main class of the network manager puppet module and
# you can define here nm module behaviour setting up parameters:
#   $erase_unmanaged_keyfiles = If you want to remove puppet unmanaged keyfiles from /etc/NetworkManager/system-connections/ directory DEFAULT: false
#   $no_auto_default = If you want to add no_auto_defaut=* option inside main /etc/NetworkManager/NetworkManager.conf config file. DEFAULT: false
#   $install_package = If you want to install puppet package from puppet module DEFAULT: true
#   $version =  version string for NetworkManager version you want to install
#   $unmanaged_devices = Array of the devices you want the networkamanger to ignore (as name or mac address, you can mix it)
#   $wait_online = enable the NetworkManager-wait-online.service DEFAULT: true
#   $use_internal_resolv_conf = use the networkmanager bundled resolver
#   $plugins = should we use different plugins to get network config data (NOT RECOMMENDED TO CHANGE)
#   $max_length_of_connection_id = Limit the name of the connection to this length. DEFAULT: 15 characters
#     to comply with kernel interface name limits since the connection $id is used as default
#     for the connection $interface_name, if you change this you neeed to take care to supply
#     the $interface_name with length < 16 characters where applicable
#   $duid_prefix = allows the cahnge of the duid prefix to anything other with format "aa:bb:cc:dd" (downcased)
#   $additional_config = Configurtion hash for the NetworkManager.conf, it id able to override default module config in case of conflict!
# @example
#   include networkmanager
#

class networkmanager (
  Boolean                               $erase_unmanaged_keyfiles = false,
  Boolean                               $no_auto_default = false,
  Boolean                               $install_package = true,
  Optional[String]                      $version = undef,
  Array[String]                         $unmanaged_devices = [],
  Boolean                               $wait_online = true,
  Variant[Boolean, Enum['stub'], Undef] $use_internal_resolv_conf = undef,
  Array[String]                         $plugins = ['keyfile'],
  Integer[3]                            $max_length_of_connection_id = 15,
  Pattern[/^\h{2}(:\h{2}){3}$/]         $duid_prefix = '00:03:00:01',
  Hash                                  $additional_config = {},
){
  $sys_id = [
    $trusted['certname'],
    $facts['certname'],
    $facts['clientcert'],
    $facts['networking']['hostname'],
  ].filter |$hn| { $hn =~ String[1] }[0]
  $duid_prefix_d = $duid_prefix.downcase
  include networkmanager::os

  include networkmanager::install

  include networkmanager::config

  include networkmanager::service

  Class['networkmanager::os']
  -> Class['networkmanager::install']
  -> Class['networkmanager::config']
  -> Class['networkmanager::service']
}

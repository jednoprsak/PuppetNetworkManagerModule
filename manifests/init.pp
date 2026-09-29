# This is main class of the network manager puppet module and
# you can define here nm module behaviour setting up parameters:
# @example
#   include networkmanager
#
# @param erase_unmanaged_keyfiles
#   If you want to remove puppet unmanaged keyfiles from /etc/NetworkManager/system-connections/ directory DEFAULT: false
# @param no_auto_default
#   If you want to add no-auto-default=* option inside main /etc/NetworkManager/NetworkManager.conf config file. DEFAULT: false
# @param install_package
#   If you want to install puppet package from puppet module DEFAULT: true
# @param version
#   version string for NetworkManager version you want to install
# @param unmanaged_devices
#   Array of the devices you want the NetworkManager to ignore (as name or mac address, you can mix it)
# @param wait_online
#   enable the NetworkManager-wait-online.service DEFAULT: true
# @param use_internal_resolv_conf
#   use the networkmanager bundled resolver
# @param plugins
#   should we use different plugins to get network config data (NOT RECOMMENDED TO CHANGE)
# @param max_length_of_connection_id
#   Limit the name of the connection to this length. DEFAULT: 15 characters
#   to comply with kernel interface name limits since the connection $id is used as default
#   for the connection $interface_name, if you change this you need to take care to supply
#   the $interface_name with length < 16 characters where applicable
# @param duid_prefix
#   allows the change of the duid prefix to anything other with format "aa:bb:cc:dd" (downcased)
# @param ipv6_dhcp_duid_default
#   the IPv6 DHCP DUID used for the connections which do not set their own $ipv6_dhcp_duid DEFAULT: 'auto'
#   'auto' builds it from the mac address of the connection (the connection needs the $mac_address), 'unset' writes nothing so NetworkManager
#   uses its own default, the NetworkManager keywords (ll, llt, lease, stable-ll, stable-llt, stable-uuid) or a literal DUID (aa:bb:cc:...) are used as they are
# @param additional_config
#   Configuration hash for the NetworkManager.conf, it is able to override default module config in case of conflict!

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
  Networkmanager::DHCP_DUID             $ipv6_dhcp_duid_default = 'auto',
  Hash                                  $additional_config = {},
) {
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

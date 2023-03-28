#This class configures file /etc/NetworkManager/NetworkManager.conf, 
#sets up whether to erase unmanaged keyfiles, and adds no-auto-default option
# inside config file according to no_auto_default parameter defined at the entrance
# of networkmanager class.
# It is not recomanded to use it without main networkmanager class.
class networkmanager::config (
  Boolean $erase_unmanaged_keyfiles = $networkmanager::erase_unmanaged_keyfiles,
  Variant[Boolean,String] $no_auto_default = $networkmanager::no_auto_default,
  Array[String] $unmanaged_devices = $networkmanager::unmanaged_devices,
  Array[String] $plugins = [ 'keyfile' ],
  Hash $additional_config = {},
  Variant[Boolean, Enum['stub'], Undef] $use_internal_resolv_conf = $networkmanager::use_internal_resolv_conf,
){
  $main_conf_file = '/etc/NetworkManager/NetworkManager.conf'
  if $unmanaged_devices != [] {
    $unmanaged_devices_c = join($unmanaged_devices.map |$dev| {
        if $dev =~ Stdlib::MAC {
          "mac:${dev}"
        }
        else {
          "interface-name:${dev}"
        }
      }, ';')
    $unmanaged = { 'keyfile' => { 'unmanaged-devices' => $unmanaged_devices_c } }
  }
  else {
    $unmanaged = {}
  }
  if $no_auto_default {
    $nauto = $no_auto_default ? {
      true    => '*',
      default => $no_auto_default,
    }
    $noauto = { 'main' => { 'no-auto-default' => $nauto } }
  }
  else {
    $noauto = {}
  }
  $default_config = { 'main' => { 'plugins' => join($plugins, ',') } }

  $main_file_settings = {
    'path'              => $main_conf_file,
    'quote_char'        => '',
    'key_val_separator' => '=',
    'require'           => File[$main_conf_file]
  }
  $main_conf_content = deep_merge($default_config, $noauto, $unmanaged, $additional_config)

  if $use_internal_resolv_conf != undef {
    case $use_internal_resolv_conf {
      'stub': {
        $link_target = '/run/NetworkManager/resolv.conf'
        $link = true
      }
      true: {
        $link_target = '/run/NetworkManager/no-stub-resolv.conf'
        $link = true
      }
      default : {
        $link_target = undef
        $link = false
      }
    }
    if $link {
      file{
        '/etc/resolv.conf':
          ensure => link,
          force  => true,
          target => $link_target;
      }
    }
    else {
      file {
        '/etc/resolv.conf':
          ensure => file,
          force  => true,
          owner  => 'root',
          group  => 'root',
          mode   => '0644';
      }
    }
  }

  file {
    $main_conf_file:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      notify  => Class['networkmanager::service'],
      content => hash2ini($main_conf_content, $main_file_settings);
    '/etc/NetworkManager/system-connections':
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      recurse => true,
      purge   => $erase_unmanaged_keyfiles,
      mode    => '0755';
 }

}

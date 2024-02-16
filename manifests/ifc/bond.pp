# This defined resource creates main bond keyfile.
# You can read parameters below.
# In the case when you want to specify special not listed parameters you can add them through additional_config hash and it will be merged with other parameters.
define networkmanager::ifc::bond (
  Enum['absent', 'present'] $ensure = present,
  Enum['up', 'down']        $state = 'up',
  String                    $id = $title, #connection name used during the start via nmcli
  String                    $type = 'bond',
  String                    $ifc_name = $title,
  Optional[String]          $master = undef,
  String                    $bond_mode = 'balance-rr',
  Enum['auto','dhcp','manual','disabled','link-local']        $ipv4_method = 'auto',
  Optional[Networkmanager::IPV4_CIDR]                      $ipv4_address = undef,
  Optional[Stdlib::IP::Address::V4::Nosubnet]                 $ipv4_gateway = undef,
  Optional[Networkmanager::DNS_IPV4]          $ipv4_dns = undef,
  Optional[Boolean]         $ipv4_may_fail = true,
  Enum['auto','dhcp','manual','ignore','link-local','disabled']        $ipv6_method = 'auto',
  Optional[Stdlib::IP::Address::V6::CIDR]                     $ipv6_address = undef,
  Optional[Stdlib::IP::Address::V6::Nosubnet]                 $ipv6_gateway = undef,
  Optional[Networkmanager::DNS_IPV6]          $ipv6_dns = undef,
  Optional[String]          $ipv6_dhcp_duid = undef,
  Variant[Integer[0, 1]]    $ipv6_addr_gen_mode = 0,
  Variant[Integer[-1, 2]]   $ipv6_privacy = 0,
  Boolean                   $ipv6_may_fail = true,
  Hash                      $additional_config = {}
)
{
  include networkmanager
  Class['networkmanager'] -> Networkmanager::Ifc::Bond[$title]

  $ipv6_method_w = networkmanager::ipv6_disable_version($ipv6_method)

  if $master {
    $connection_config = {
      connection => {
        id => $id,
        uuid => networkmanager::connection_uuid($id),
        type => $type,
        interface-name => $ifc_name,
        master => $master,
      },
      bond => {
        mode => $bond_mode
      }
    }
  }
  elsif !$master {
    $connection_config = {
      connection => {
        id => $id,
        uuid => networkmanager::connection_uuid($id),
        type => $type,
        interface-name => $ifc_name,
      },
      bond => {
        mode => $bond_mode
      }
    }
  }


  if ($ipv4_method == 'manual' or $ipv4_address) and $ipv4_gateway {
    $ipv4_config = {
      ipv4 => {
       method => $ipv4_method,
       address => $ipv4_address,
       gateway => $ipv4_gateway,
       dns => $ipv4_dns,
       may-fail => $ipv4_may_fail
      }
    }
  }
  elsif ($ipv4_method == 'manual' or $ipv4_address) and !$ipv4_gateway {
    $ipv4_config = {
      ipv4 => {
       method => $ipv4_method,
       address => $ipv4_address,
       dns => $ipv4_dns,
       may-fail => $ipv4_may_fail
      }
    }
  }
  elsif $ipv4_method == 'auto' or $ipv4_method == 'dhcp' {
    $ipv4_config = {
      ipv4 => {
       method => $ipv4_method,
       dns => $ipv4_dns,
       may-fail => $ipv4_may_fail
      }
    }
  }
  elsif $ipv4_method == 'disabled' or ipv4_method == 'link-local' {
    $ipv4_config = {
      ipv4 => {
        method => $ipv4_method
      }
    }
  }

  if ($ipv6_method_w == 'manual' or $ipv6_address) and $ipv6_gateway {
    $ipv6_config = {
      ipv6 => {
        method => 'manual',
        address => $ipv6_address,
        gateway => $ipv6_gateway,
        addr-gen-mode => $ipv6_addr_gen_mode,
        ip6-privacy => $ipv6_privacy,
        may-fail => $ipv6_may_fail,
        dns => $ipv6_dns,
      }
    }
  }
  elsif ($ipv6_method_w == 'manual' or $ipv6_address) and !$ipv6_gateway {
    $ipv6_config = {
      ipv6 => {
        method => 'manual',
        address => $ipv6_address,
        addr-gen-mode => $ipv6_addr_gen_mode,
        ip6-privacy => $ipv6_privacy,
        may-fail => $ipv6_may_fail,
        dns => $ipv6_dns,
      }
    }
  }
  elsif $ipv6_dhcp_duid == undef and ($ipv6_method_w == 'auto' or $ipv6_method_w == 'dhcp' ) and 'present' == $ensure
  {
    fail("IPv6 method for connection '${id}' is '${ipv6_method_w}' but no \$ipv6_dhcp_duid was supplied.")
  }
  elsif $ipv6_method_w == 'auto' or ipv6_method_w == 'dhcp'
  {
   $ipv6_config = {
      ipv6 => {
        method => $ipv6_method_w,
        address => $ipv6_address,
        addr-gen-mode => $ipv6_addr_gen_mode,
        ip6-privacy => $ipv6_privacy,
        may-fail => $ipv6_may_fail,
        dns => $ipv6_dns,
        dhcp-duid => $ipv6_dhcp_duid
      }
   }
  }
  elsif $ipv6_method_w in ['ignore','link-local','disabled'] {
    $ipv6_config = {
      ipv6 => {
        method => $ipv6_method_w
      }
    }
  }

  $keyfile_contents = deep_merge($connection_config, $ipv4_config, $ipv6_config, $additional_config)
  $keyfile_settings = {
    'path'              => "/etc/NetworkManager/system-connections/${id}.nmconnection",
    'quote_char'        => '',
    'key_val_separator' => '=',
    'require'           => File["/etc/NetworkManager/system-connections/${id}.nmconnection"]
  }

  file {
     "/etc/NetworkManager/system-connections/${id}.nmconnection":
     ensure  => $ensure,
     owner   => 'root',
     group   => 'root',
     replace => true,
     mode    => '0600',
     content => hash2ini($keyfile_contents,$keyfile_settings);
  }

  if $ensure == present {

#  @@exec { "activate ${id}":
#     command => networkmanager::reload_connection($id, $state),
#     provider    => 'shell',
#     group => 'root',
#     user => 'root',
#     subscribe => File["/etc/NetworkManager/system-connections/${id}.nmconnection"],
#     refreshonly => true,
#     tag => "nmactivate-2022b07${networkmanager::sys_id}";
#  }
   networkmanager::activate_connection($id, $state)

  }

  include networkmanager::reload
  Networkmanager::Ifc::Bond[$title] ~> Class['networkmanager::reload']
}

# Reference

Generated from the manifests, functions and types of the module. The user facing parts are the classes and defined types listed under "Classes" and "Defined types".

## Classes

### `networkmanager`

This is main class of the network manager puppet module and you can define here nm module behaviour setting up parameters:

Parameters:

* `erase_unmanaged_keyfiles` (`Boolean`) — default: `false` — If you want to remove puppet unmanaged keyfiles from /etc/NetworkManager/system-connections/ directory DEFAULT: false
* `no_auto_default` (`Boolean`) — default: `false` — If you want to add no-auto-default=* option inside main /etc/NetworkManager/NetworkManager.conf config file. DEFAULT: false
* `install_package` (`Boolean`) — default: `true` — If you want to install puppet package from puppet module DEFAULT: true
* `version` (`Optional[String]`) — default: `undef` — version string for NetworkManager version you want to install
* `unmanaged_devices` (`Array[String]`) — default: `[]` — Array of the devices you want the NetworkManager to ignore (as name or mac address, you can mix it)
* `wait_online` (`Boolean`) — default: `true` — enable the NetworkManager-wait-online.service DEFAULT: true
* `use_internal_resolv_conf` (`Variant[Boolean, Enum['stub'], Undef]`) — default: `undef` — use the networkmanager bundled resolver
* `plugins` (`Array[String]`) — default: `['keyfile']` — should we use different plugins to get network config data (NOT RECOMMENDED TO CHANGE)
* `max_length_of_connection_id` (`Integer[3]`) — default: `15` — Limit the name of the connection to this length. DEFAULT: 15 characters to comply with kernel interface name limits since the connection $id is used as default for the connection $interface_name, if you change this you need to take care to supply the $interface_name with length < 16 characters where applicable
* `duid_prefix` (`Pattern[/^\h{2}(:\h{2}){3}$/]`) — default: `'00:03:00:01'` — allows the change of the duid prefix to anything other with format "aa:bb:cc:dd" (downcased)
* `ipv6_dhcp_duid_default` (`Networkmanager::DHCP_DUID`) — default: `'auto'` — the IPv6 DHCP DUID used for the connections which do not set their own $ipv6_dhcp_duid DEFAULT: 'auto' 'auto' builds it from the mac address of the connection (the connection needs the $mac_address), 'unset' writes nothing so NetworkManager uses its own default, the NetworkManager keywords (ll, llt, lease, stable-ll, stable-llt, stable-uuid) or a literal DUID (aa:bb:cc:...) are used as they are
* `additional_config` (`Hash`) — default: `{}` — Configuration hash for the NetworkManager.conf, it is able to override default module config in case of conflict!

### `networkmanager::config`

This class configures file /etc/NetworkManager/NetworkManager.conf, sets up whether to erase unmanaged keyfiles, and adds no-auto-default option inside config file according to no_auto_default parameter defined at the entrance of networkmanager class. It is not recommended to use it without main networkmanager class.

Parameters:

* `erase_unmanaged_keyfiles` (`Boolean`) — default: `$networkmanager::erase_unmanaged_keyfiles` — Taken from `$networkmanager::erase_unmanaged_keyfiles`
* `no_auto_default` (`Variant[Boolean,String]`) — default: `$networkmanager::no_auto_default` — Taken from `$networkmanager::no_auto_default`
* `unmanaged_devices` (`Array[String]`) — default: `$networkmanager::unmanaged_devices` — Taken from `$networkmanager::unmanaged_devices`
* `plugins` (`Array[String]`) — default: `$networkmanager::plugins` — Taken from `$networkmanager::plugins`
* `use_internal_resolv_conf` (`Variant[Boolean, Enum['stub'], Undef]`) — default: `$networkmanager::use_internal_resolv_conf` — Taken from `$networkmanager::use_internal_resolv_conf`
* `additional_config` (`Hash`) — default: `$networkmanager::additional_config` — Settings merged over the NetworkManager.conf built by the module, they win in case of a conflict. Taken from `$networkmanager::additional_config`

### `networkmanager::install`

This class handles the installation of the NetworkManager packages Not to be used by user

Parameters:

* `install_package` (`Boolean`) — default: `$networkmanager::install_package` — Taken from `$networkmanager::install_package`
* `package_name` (`String`) — default: `$networkmanager::os::package_name` — Taken from `$networkmanager::os::package_name`
* `extra_packages` (`Array`) — default: `$networkmanager::os::extra_packages` — Taken from `$networkmanager::os::extra_packages`
* `install_extra_packages` (`Boolean`) — default: `$networkmanager::install_package` — Taken from `$networkmanager::install_package`
* `version` (`Optional[String]`) — default: `$networkmanager::version` — Taken from `$networkmanager::version`

### `networkmanager::notify_ipv6_disabled`

To be included from networkmanager::ipv6_disable_version when incompatible $ipv6_method is detected to inform the user

### `networkmanager::os`

This class sets the OS specific variables (package names) of the networkmanager module. Not to be used by user

### `networkmanager::reload`

This class is used to collect different keyfile activation exported resources and apply them. Not to be used by user

### `networkmanager::service`

This class manages NetworkManager services Not to be used by user

Parameters:

* `wait_online` (`Boolean`) — default: `$networkmanager::wait_online` — Taken from `$networkmanager::wait_online`

## Defined types

### `networkmanager::connection_keyfile_manage`

This defined resource manages the connection keyfiles It should not be used by user

Parameters:

* `content` (`Hash`) — The keyfile as a hash of the sections, each section is a hash of the settings (rendered by the templates/ini.epp)
* `ensure` (`Enum['absent', 'present']`) — default: `present` — state of the interface config DEFAULT: present

### `networkmanager::ifc::bond`

This defined resource creates master bond keyfile.

Parameters:

* `ensure` (`Enum['absent', 'present']`) — default: `present` — state of the interface config DEFAULT: present
* `state` (`Enum['up', 'down']`) — default: `'up'` — state of the interface (UP/DOWN) not relevant when $ensure == 'absent' DEFAULT: 'up'
* `id` (`String`) — default: `$title` — the name of the connection DEFAULT: $title of the resource
* `interface_name` (`String[3, 15]`) — default: `$title` — name of the connection interface DEFAULT: $title of the resource
* `mac_address` (`Optional[Stdlib::MAC]`) — default: `undef` — the mac of the interface for the connection
* `master` (`Optional[String]`) — default: `undef` — $id or UUID of the connection master if applicable
* `bond_mode` (`Variant[Integer[0, 6], Enum['balance-rr', 'active-backup', 'balance-xor', 'broadcast', '802.3ad', 'balance-tlb', 'balance-alb']]`) — default: `'balance-rr'` — bonding mode DEFAULT: 'balance-rr'
* `ipv4_method` (`Enum['auto','dhcp','manual','disabled','link-local']`) — default: `'auto'` — what method to use to get an IPv4 address DEFAULT: 'auto'
* `ipv4_address` (`Optional[Networkmanager::IPV4_ADDRESSES]`) — default: `undef` — the IPv4 address with the prefix length and an optional gateway (192.0.2.12/24 or 192.0.2.12/24,192.0.2.1), more addresses as an array or as a string separated by a semicolon (192.0.2.12/24;198.51.100.12/24)
* `ipv4_gateway` (`Optional[Stdlib::IP::Address::V4::Nosubnet]`) — default: `undef` — the IPv4 gateway for the connection
* `ipv4_dns` (`Optional[Networkmanager::DNS_IPV4]`) — default: `undef` — up to 5 DNS servers for the IPv4: an array of addresses or a string with the addresses separated by a semicolon (192.0.2.53;192.0.2.54;)
* `ipv4_may_fail` (`Boolean`) — default: `true` — is it OK that the IPv4 config fails? DEFAULT: true
* `ipv6_method` (`Enum['auto','dhcp','manual','ignore','link-local','disabled']`) — default: `'auto'` — what method to use to get an ipv6 address DEFAULT: 'auto'
* `ipv6_address` (`Optional[Networkmanager::IPV6_ADDRESSES]`) — default: `undef` — the IPv6 address with the prefix length (2001:db8::12/64), more addresses as an array or as a string separated by a semicolon (2001:db8::12/64;2001:db8:1::12/64)
* `ipv6_gateway` (`Optional[Stdlib::IP::Address::V6::Nosubnet]`) — default: `undef` — the ipv6 gateway for the connection
* `ipv6_dns` (`Optional[Networkmanager::DNS_IPV6]`) — default: `undef` — up to 5 DNS servers for the IPv6: an array of addresses or a string with the addresses separated by a semicolon (2001:db8::53;2001:db8::54;)
* `ipv6_dhcp_duid` (`Optional[Networkmanager::DHCP_DUID]`) — default: `undef` — IPv6 DHCP DUID, 'auto' builds it from the $mac_address, 'unset' writes nothing (NetworkManager default), a NetworkManager keyword or a literal DUID is used as it is DEFAULT: $networkmanager::ipv6_dhcp_duid_default
* `ipv6_addr_gen_mode` (`Integer[0, 3]`) — default: `0` — IPv6 method for generating of automatic interface address
* `ipv6_privacy` (`Integer[-1, 2]`) — default: `0` — should be the generated automatic address more private
* `ipv6_may_fail` (`Boolean`) — default: `true` — is it OK that the ipv6 config fails? DEFAULT: true
* `additional_config` (`Hash`) — default: `{}` — Other not covered configuration In the case when you want to specify special not listed parameters you can add them through $additional_config hash and it will be merged with other parameters. The additional_config has the HIGHEST priority when merged! ie: it will override the defined values of the connection in case of the conflict

### `networkmanager::ifc::bond::slave`

This defined resource creates bond slave keyfile.

Parameters:

* `master` (`String`) — $id or UUID of the master interface under which this slave should operate REQUIRED
* `ensure` (`Enum['absent', 'present']`) — default: `present` — state of the interface config DEFAULT: present
* `state` (`Enum['up', 'down']`) — default: `'up'` — state of the interface (UP/DOWN) not relevant when $ensure == 'absent' DEFAULT: 'up'
* `id` (`String`) — default: `$title` — the name of the connection DEFAULT: $title of the resource
* `type` (`String`) — default: `'ethernet'` — connection type DEFAULT: ethernet
* `mac_address` (`Optional[Stdlib::MAC]`) — default: `undef` — the mac of the interface for the connection REQUIRED IF $ifc_name was not supplied
* `interface_name` (`Optional[String[3, 15]]`) — default: `undef` — name of the connection interface REQUIRED IF $mac_address was not supplied
* `additional_config` (`Hash`) — default: `{}` — Other not covered configuration In the case when you want to specify special not listed parameters you can add them through $additional_config hash and it will be merged with other parameters. The additional_config has the HIGHEST priority when merged! ie: it will override the defined values of the connection in case of the conflict

### `networkmanager::ifc::bridge`

This defined resource creates master bridge keyfile.

Parameters:

* `ensure` (`Enum['absent', 'present']`) — default: `present` — state of the interface config DEFAULT: present
* `state` (`Enum['up', 'down']`) — default: `'up'` — state of the interface (UP/DOWN) not relevant when $ensure == 'absent' DEFAULT: 'up'
* `id` (`String`) — default: `$title` — the name of the connection DEFAULT: $title of the resource
* `interface_name` (`String[3, 15]`) — default: `$title` — name of the connection interface DEFAULT: $title of the resource
* `mac_address` (`Optional[Stdlib::MAC]`) — default: `undef` — the mac of the interface for the connection
* `master` (`Optional[String]`) — default: `undef` — $id or UUID of the connection master if applicable
* `bridge_stp` (`Boolean`) — default: `true` — bridge the spanning tree protocol
* `bridge_forward_delay` (`Integer[0]`) — default: `15` — delay of forwarding in seconds
* `ipv4_method` (`Enum['auto','dhcp','manual','disabled','link-local']`) — default: `'auto'` — what method to use to get an IPv4 address DEFAULT: 'auto'
* `ipv4_address` (`Optional[Networkmanager::IPV4_ADDRESSES]`) — default: `undef` — the IPv4 address with the prefix length and an optional gateway (192.0.2.12/24 or 192.0.2.12/24,192.0.2.1), more addresses as an array or as a string separated by a semicolon (192.0.2.12/24;198.51.100.12/24)
* `ipv4_gateway` (`Optional[Stdlib::IP::Address::V4::Nosubnet]`) — default: `undef` — the IPv4 gateway for the connection
* `ipv4_dns` (`Optional[Networkmanager::DNS_IPV4]`) — default: `undef` — up to 5 DNS servers for the IPv4: an array of addresses or a string with the addresses separated by a semicolon (192.0.2.53;192.0.2.54;)
* `ipv4_may_fail` (`Boolean`) — default: `true` — is it OK that the IPv4 config fails? DEFAULT: true
* `ipv6_method` (`Enum['auto','dhcp','manual','ignore','link-local','disabled']`) — default: `'auto'` — what method to use to get an ipv6 address DEFAULT: 'auto'
* `ipv6_address` (`Optional[Networkmanager::IPV6_ADDRESSES]`) — default: `undef` — the IPv6 address with the prefix length (2001:db8::12/64), more addresses as an array or as a string separated by a semicolon (2001:db8::12/64;2001:db8:1::12/64)
* `ipv6_gateway` (`Optional[Stdlib::IP::Address::V6::Nosubnet]`) — default: `undef` — the ipv6 gateway for the connection
* `ipv6_dns` (`Optional[Networkmanager::DNS_IPV6]`) — default: `undef` — up to 5 DNS servers for the IPv6: an array of addresses or a string with the addresses separated by a semicolon (2001:db8::53;2001:db8::54;)
* `ipv6_dhcp_duid` (`Optional[Networkmanager::DHCP_DUID]`) — default: `undef` — IPv6 DHCP DUID, 'auto' builds it from the $mac_address, 'unset' writes nothing (NetworkManager default), a NetworkManager keyword or a literal DUID is used as it is DEFAULT: $networkmanager::ipv6_dhcp_duid_default
* `ipv6_addr_gen_mode` (`Integer[0, 3]`) — default: `0` — IPv6 method for generating of automatic interface address
* `ipv6_privacy` (`Integer[-1, 2]`) — default: `0` — should be the generated automatic address more private
* `ipv6_may_fail` (`Boolean`) — default: `true` — is it OK that the ipv6 config fails? DEFAULT: true
* `additional_config` (`Hash`) — default: `{}` — Other not covered configuration In the case when you want to specify special not listed parameters you can add them through $additional_config hash and it will be merged with other parameters. The additional_config has the HIGHEST priority when merged! ie: it will override the defined values of the connection in case of the conflict

### `networkmanager::ifc::bridge::slave`

This defined resource creates bridge slave keyfile.

Parameters:

* `master` (`String`) — $id or UUID of the master interface under which this slave should operate REQUIRED
* `ensure` (`Enum['absent', 'present']`) — default: `present` — state of the interface config DEFAULT: present
* `state` (`Enum['up', 'down']`) — default: `'up'` — state of the interface (UP/DOWN) not relevant when $ensure == 'absent' DEFAULT: 'up'
* `id` (`String`) — default: `$title` — the name of the connection DEFAULT: $title of the resource
* `type` (`String`) — default: `'ethernet'` — connection type DEFAULT: ethernet
* `mac_address` (`Optional[Stdlib::MAC]`) — default: `undef` — the mac of the interface for the connection REQUIRED IF $ifc_name was not supplied
* `interface_name` (`Optional[String[3, 15]]`) — default: `undef` — name of the connection interface REQUIRED IF $mac_address was not supplied
* `additional_config` (`Hash`) — default: `{}` — Other not covered configuration In the case when you want to specify special not listed parameters you can add them through $additional_config hash and it will be merged with other parameters. The additional_config has the HIGHEST priority when merged! ie: it will override the defined values of the connection in case of the conflict

### `networkmanager::ifc::connection`

This defined resource creates the connection keyfile.

Parameters:

* `ensure` (`Enum['absent', 'present']`) — default: `present` — state of the interface config DEFAULT: present
* `state` (`Enum['up', 'down']`) — default: `'up'` — state of the interface (UP/DOWN) not relevant when $ensure == 'absent' DEFAULT: 'up'
* `id` (`String`) — default: `$title` — the name of the connection DEFAULT: $title of the resource
* `interface_name` (`Optional[String[3, 15]]`) — default: `undef` — name of the connection interface, an ethernet connection without the $interface_name and the $mac_address uses the $title of the resource
* `mac_address` (`Optional[Stdlib::MAC]`) — default: `undef` — the mac of the interface for the connection
* `master` (`Optional[String]`) — default: `undef` — $id or UUID of the connection master if applicable
* `type` (`String`) — default: `'ethernet'` — the type of the connection DEFAULT: 'ethernet'
* `ipv4_method` (`Enum['auto', 'dhcp', 'manual', 'disabled', 'link-local']`) — default: `'auto'` — what method to use to get an IPv4 address DEFAULT: 'auto'
* `ipv4_address` (`Optional[Networkmanager::IPV4_ADDRESSES]`) — default: `undef` — the IPv4 address with the prefix length and an optional gateway (192.0.2.12/24 or 192.0.2.12/24,192.0.2.1), more addresses as an array or as a string separated by a semicolon (192.0.2.12/24;198.51.100.12/24)
* `ipv4_dns` (`Optional[Networkmanager::DNS_IPV4]`) — default: `undef` — up to 5 DNS servers for the IPv4: an array of addresses or a string with the addresses separated by a semicolon (192.0.2.53;192.0.2.54;)
* `ipv4_may_fail` (`Boolean`) — default: `true` — is it OK that the IPv4 config fails? DEFAULT: true
* `ipv4_gateway` (`Optional[Stdlib::IP::Address::V4::Nosubnet]`) — default: `undef` — the IPv4 gateway for the connection
* `ipv6_method` (`Enum['auto', 'dhcp', 'manual', 'ignore', 'link-local', 'disabled']`) — default: `'auto'` — what method to use to get an ipv6 address DEFAULT: 'auto'
* `ipv6_address` (`Optional[Networkmanager::IPV6_ADDRESSES]`) — default: `undef` — the IPv6 address with the prefix length (2001:db8::12/64), more addresses as an array or as a string separated by a semicolon (2001:db8::12/64;2001:db8:1::12/64)
* `ipv6_gateway` (`Optional[Stdlib::IP::Address::V6::Nosubnet]`) — default: `undef` — the ipv6 gateway for the connection
* `ipv6_dns` (`Optional[Networkmanager::DNS_IPV6]`) — default: `undef` — up to 5 DNS servers for the IPv6: an array of addresses or a string with the addresses separated by a semicolon (2001:db8::53;2001:db8::54;)
* `ipv6_dhcp_duid` (`Optional[Networkmanager::DHCP_DUID]`) — default: `undef` — IPv6 DHCP DUID, 'auto' builds it from the $mac_address, 'unset' writes nothing (NetworkManager default), a NetworkManager keyword or a literal DUID is used as it is DEFAULT: $networkmanager::ipv6_dhcp_duid_default
* `ipv6_addr_gen_mode` (`Integer[0, 3]`) — default: `0` — IPv6 method for generating of automatic interface address
* `ipv6_privacy` (`Integer[-1, 2]`) — default: `0` — should be the generated automatic address more private
* `ipv6_may_fail` (`Boolean`) — default: `true` — is it OK that the ipv6 config fails? DEFAULT: true
* `additional_config` (`Hash`) — default: `{}` — Other not covered configuration In the case when you want to specify special not listed parameters you can add them through $additional_config hash and it will be merged with other parameters. The additional_config has the HIGHEST priority when merged! ie: it will override the defined values of the connection in case of the conflict

### `networkmanager::ifc::fallback`

This defined resource creates the user defined connection keyfile. Notes: This resource supplies some, hopefully sane, defaults you can override in the $config parameter connection.uuid = generated by the module unless it is already an uuid connection.type = DEFAULT: ethernet ethernet.auto-negotiate = true ipv4.method = auto ipv6.method = auto WARNING: The name of master or parent are translated to uuid unless they are provided as uuids! You can not override this behaviour.

Parameters:

* `config` (`Hash`) — The definition of the connection REQUIRED
* `ensure` (`Enum['absent', 'present']`) — default: `present` — state of the interface config DEFAULT: present
* `state` (`Enum['up', 'down']`) — default: `'up'` — state of the interface (UP/DOWN) not relevant when $ensure == 'absent' DEFAULT: 'up'
* `id` (`String`) — default: `$title` — the name of the connection DEFAULT: $title of the resource

### `networkmanager::ifc::vlan`

This defined resource creates the vlan connection keyfile.

Parameters:

* `vlan_id` (`Integer[1, 4094]`) — id of the desired vlan REQUIRED
* `vlan_parent` (`String`) — $id of the parent connection managed by this module or the plain UUID (without any prefix like 'UUID=') of the parent connection REQUIRED The parent interface name is not supported, if the parent is not managed by this module find out its UUID yourself and supply it.
* `ensure` (`Enum['absent', 'present']`) — default: `present` — state of the interface config DEFAULT: present
* `state` (`Enum['up', 'down']`) — default: `'up'` — state of the interface (UP/DOWN) not relevant when $ensure == 'absent' DEFAULT: 'up'
* `id` (`String`) — default: `$title` — the name of the connection DEFAULT: $title of the resource
* `interface_name` (`String[3, 15]`) — default: `$title` — name of the connection interface DEFAULT: $title of the resource
* `master` (`Optional[String]`) — default: `undef` — $id or UUID of the connection master if applicable
* `slave_type` (`String`) — default: `'bridge'` — type which this port should assume if set as slave (IGNORED if $master == undef)
* `vlan_flags` (`Integer[0]`) — default: `1` — flags for the 802.1Q vlan protocol DEFAULT: 1
* `additional_config` (`Hash`) — default: `{}` — Other not covered configuration In the case when you want to specify special not listed parameters you can add them through $additional_config hash and it will be merged with other parameters. The additional_config has the HIGHEST priority when merged! ie: it will override the defined values of the connection in case of the conflict

## Functions

### `networkmanager::activate_connection`

Activates the connection after configuration parameters: $uuid  = uuid of the connection as generated by networkmanager::connection_uuid function or supplied by user $id    = name of the connection (here used for a file name) $state = the connection state Additional variables: $networkmanager::sys_id = system name

Parameters:

* `uuid` (`Pattern[/^\h{8}-(\h{4}-){3}\h{12}$/]`)
* `id` (`String[3]`)
* `state` (`Enum['up', 'down']`)

### `networkmanager::address_settings`

Returns the keyfile settings with the IP addresses of the connection: a single address is written as `address`, more addresses as `address1`, `address2` and so on (the format used by NetworkManager itself). The addresses can be given as an array or as a string with the addresses separated by a semicolon. Parameters: $addresses = the address (with the prefix length) or the addresses, undef returns no settings

Returns: `Hash`

Parameters:

* `addresses` (`Optional[Variant[String, Array[String]]]`)

### `networkmanager::compact_keyfile`

Removes the undefined settings and the empty sections from a keyfile hash, so the caller can list every optional setting in one literal instead of building it up conditionally. Parameters: $sections = hash of sections, each one a hash of settings (undef values are dropped)

Returns: `Hash`

Parameters:

* `sections` (`Hash[String, Hash]`)

### `networkmanager::connection_duid`

Returns IPv6 DHCP DUID Parameters: $mac = MAC address of the interface Additional variables: $networkmanager::duid_prefix = prefix for the dhcp duid (taken from the networkmanager class)

Returns: `String`

Parameters:

* `mac` (`Stdlib::MAC`)

### `networkmanager::connection_uuid`

Returns stable connection uuid unless connection $id is uuid already. Parameters: $id = connection id

Returns: `String`

Parameters:

* `id` (`String`)

### `networkmanager::dns_list`

Converts the DNS servers to the string used by the keyfile: the addresses separated and terminated by a semicolon. The string (the legacy format) and undef are returned unchanged. Parameters: $dns = array of DNS server addresses or already formatted string

Returns: `Optional[String]`

Parameters:

* `dns` (`Optional[Variant[String, Array[String]]]`)

### `networkmanager::ini_value`

Formats a value for the NetworkManager keyfile (GLib key file format): the values are not quoted, the backslash, the new line, the tab, the carriage return and the leading or trailing space are escaped and an array is written as the list of values terminated by a semicolon (eg. 'a;b;'). A string is only escaped, so an already formatted list (eg. '192.0.2.53;') is left as it is. Parameters: $value = the value to format (string, number, boolean, undef or an array of them)

Returns: `String`

Parameters:

* `value` (`Variant[Undef, Boolean, Numeric, String, Array[Variant[Boolean, Numeric, String]]]`)

### `networkmanager::ipv6_disable_version`

Ensures that the 'ignore' is returned when the 'disable' keyword is used on the NetworkManager version < 1.20 Parameters: $ipv6_method = IPv6 IP method of the interface

Returns: `String`

Parameters:

* `ipv6_method` (`Enum['auto', 'dhcp', 'manual', 'ignore', 'link-local', 'disabled']`)

### `networkmanager::prepare_ipv4_config`

Prepares the "ipv4" section of the keyfile. Only the method is written when the IPv4 is disabled, the other settings would have no effect. Based on the idea of the pull request 24 by kbucheli. Parameters: $ipv4_method = what method to use to get an IPv4 address $ipv4_address = the IPv4 address(es) to assign to the interface, see networkmanager::address_settings $ipv4_gateway = the IPv4 gateway for the connection $ipv4_dns = the dns servers for the interface (array or semicolon separated string) $ipv4_may_fail = is it OK that the IPv4 config fails?

Returns: `Hash`

Parameters:

* `ipv4_method` (`Enum['auto', 'dhcp', 'manual', 'disabled', 'link-local']`)
* `ipv4_address` (`Optional[Networkmanager::IPV4_ADDRESSES]`)
* `ipv4_gateway` (`Optional[Stdlib::IP::Address::V4::Nosubnet]`)
* `ipv4_dns` (`Optional[Networkmanager::DNS_IPV4]`)
* `ipv4_may_fail` (`Boolean`)

### `networkmanager::prepare_ipv6_config`

Prepares the "ipv6" section of the keyfile. Only the method is written when the IPv6 is ignored or disabled, the other settings would have no effect. Based on the idea of the pull request 24 by kbucheli. Parameters: $ipv6_method = what method to use to get an IPv6 address (already adjusted by networkmanager::ipv6_disable_version) $ipv6_address = the IPv6 address(es) to assign to the interface, see networkmanager::address_settings $ipv6_gateway = the IPv6 gateway for the connection $ipv6_dns = the dns servers for the interface (array or semicolon separated string) $ipv6_addr_gen_mode = IPv6 method for generating of automatic interface address $ipv6_privacy = should be the generated automatic address more private $ipv6_may_fail = is it OK that the IPv6 config fails? $ipv6_dhcp_duid = the IPv6 DHCP DUID, undef when it should not be written

Returns: `Hash`

Parameters:

* `ipv6_method` (`Enum['auto', 'dhcp', 'manual', 'ignore', 'link-local', 'disabled']`)
* `ipv6_address` (`Optional[Networkmanager::IPV6_ADDRESSES]`)
* `ipv6_gateway` (`Optional[Stdlib::IP::Address::V6::Nosubnet]`)
* `ipv6_dns` (`Optional[Networkmanager::DNS_IPV6]`)
* `ipv6_addr_gen_mode` (`Integer[0, 3]`)
* `ipv6_privacy` (`Integer[-1, 2]`)
* `ipv6_may_fail` (`Boolean`)
* `ipv6_dhcp_duid` (`Optional[String]`)

### `networkmanager::reload_connection`

Reloads the connection through the dbus Parameters: $uuid = the connection uuid $state = the desired connection state

Returns: `String`

Parameters:

* `uuid` (`Pattern[/^\h{8}-(\h{4}-){3}\h{12}$/]`)
* `state` (`Enum['up', 'down']`)

### `networkmanager::resolve_ipv6_duid`

Returns the IPv6 DHCP DUID to write to the keyfile of the connection, undef when nothing should be written. The DUID is written only for the 'auto' and 'dhcp' methods of an active connection. The DUID of the connection wins, the $networkmanager::ipv6_dhcp_duid_default is used when it is not set. The 'auto' DUID needs the mac address. Parameters: $duid = the DUID set for the connection (undef to use the default of the networkmanager class) $mac_address = the mac address of the interface for the connection $ipv6_method = the IPv6 method of the connection (after networkmanager::ipv6_disable_version) $ensure = the state of the connection config $state = the state of the connection (up/down) $id = the id of the connection (for the error message)

Returns: `Optional[String]`

Parameters:

* `duid` (`Optional[Networkmanager::DHCP_DUID]`)
* `mac_address` (`Optional[Stdlib::MAC]`)
* `ipv6_method` (`String`)
* `ensure` (`String`)
* `state` (`String`)
* `id` (`String`)

### `networkmanager::validate_ifc_name_and_mac`

Validates that the connection has at least one of 'mac address' or 'interface name' supplied Parameters: $caller = the puppet name of the resource which called this function (for sensible error line) $caller_title = the instance of the resource which called the function (for sensible error line) $interface_mac = the connection interface mac address $ine4terface_name = the connection interface name

Returns: `Hash`

Parameters:

* `caller` (`String`)
* `caller_title` (`String`)
* `interface_mac` (`Variant[Undef, Stdlib::MAC]`)
* `interface_name` (`Variant[Undef, String[3, 15]]`)

## Data types

### `Networkmanager::DHCP_DUID`

The IPv6 DHCP DUID of a connection: 'auto' builds it from the mac address of the interface (see the duid_prefix of the networkmanager class), 'unset' does not write it so NetworkManager uses its own default, the other values are the NetworkManager keywords or a literal DUID (aa:bb:cc:...)

Alias of:

```puppet
type Networkmanager::DHCP_DUID = Variant[
  Pattern[/\A\h{2}(:\h{2})+\z/],
  Enum['auto', 'unset', 'lease', 'll', 'llt', 'stable-ll', 'stable-llt', 'stable-uuid'],
]
```

### `Networkmanager::DNS_IPV4`

Up to 5 IPv4 DNS server addresses, either as an array of addresses (eg. ['192.0.2.53', '192.0.2.54']) or as the keyfile string with the addresses separated by a semicolon (eg. '192.0.2.53;192.0.2.54;')

Alias of:

```puppet
type Networkmanager::DNS_IPV4 = Variant[
  Pattern[/\A(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}(;(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}){0,4};?\z/],
  Array[Stdlib::IP::Address::V4::Nosubnet, 1, 5],
]
```

### `Networkmanager::DNS_IPV6`

Up to 5 IPv6 DNS server addresses, either as an array of addresses (eg. ['2001:db8::53', 'fd00::1']) or as the keyfile string with the addresses (full or compressed form) separated by a semicolon (eg. '2001:db8::53;fd00::1;')

Alias of:

```puppet
type Networkmanager::DNS_IPV6 = Variant[
  Pattern[/\A[[:xdigit:]:.]+(;[[:xdigit:]:.]+){0,4};?\z/],
  Array[Stdlib::IP::Address::V6::Nosubnet, 1, 5],
]
```

### `Networkmanager::IPV4_ADDRESSES`

One or more IPv4 addresses with the prefix length (eg. '192.168.1.12/24', optionally followed by the gateway), as an array or as a string with the addresses separated by a semicolon (eg. '192.168.1.12/24;192.168.2.12/24')

Alias of:

```puppet
type Networkmanager::IPV4_ADDRESSES = Variant[
  Networkmanager::IPV4_CIDR,
  Array[Networkmanager::IPV4_CIDR, 1],
  Pattern[/\A(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}\/([12]?[0-9]|3[0-2])(;(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}\/([12]?[0-9]|3[0-2]))+;?\z/],
]
```

### `Networkmanager::IPV4_CIDR`

IPv4 address with the prefix length, optionally followed by a gateway (eg. '192.168.1.12/24' or '192.168.1.12/24,192.168.1.1')

Alias of:

```puppet
type Networkmanager::IPV4_CIDR = Variant[
  Stdlib::IP::Address::V4::CIDR,
  Pattern[/\A(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}\/([12]?[0-9]|3[0-2]),(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}\z/],
]
```

### `Networkmanager::IPV6_ADDRESSES`

One or more IPv6 addresses with the prefix length (eg. '2001:db8::5/64'), as an array or as a string with the addresses separated by a semicolon (eg. '2001:db8::5/64;2001:db8:1::5/64')

Alias of:

```puppet
type Networkmanager::IPV6_ADDRESSES = Variant[
  Stdlib::IP::Address::V6::CIDR,
  Array[Stdlib::IP::Address::V6::CIDR, 1],
  Pattern[/\A[[:xdigit:]:.]+\/[0-9]{1,3}(;[[:xdigit:]:.]+\/[0-9]{1,3})+;?\z/],
]
```

## Facts

### `networkmanager`

Structured fact set by `lib/facter/networkmanager_version.rb` when the `NetworkManager` binary is found. It contains `version` with `full`, `major`, `minor`, `build`, `patch` and `suffix` (where available) and is used to adapt the IPv6 `disabled` method to NetworkManager older than 1.20.

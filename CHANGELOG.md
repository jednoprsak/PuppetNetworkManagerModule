# CHANGELOG
## 1.0.0-rc1 -> 1.1.0
* Behaviour changes to check when upgrading:
    - the values are validated more strictly: the `Networkmanager::DNS_IPV4`, `DNS_IPV6` and `IPV4_CIDR` types used unanchored patterns and accepted almost any string, they now validate the whole value; `$ipv6_dhcp_duid` of `connection` (any string before) is validated by the new `Networkmanager::DHCP_DUID` type as it is in `bond` and `bridge`; a malformed value which used to slip through now fails to compile
    - the values of the keyfiles are formatted by `networkmanager::ini_value` according to the GLib key file rules: arrays are written as `a;b;` (they were rendered as `[a, b]`), the backslash, new line, tab, carriage return and edge spaces are escaped so that a value can not break the file
    - only the `method` is written to the `ipv4` section when it is `disabled` and to the `ipv6` section when it is `ignore` or `disabled`, the other settings have no effect there (the idea of the pull request jednoprsak/PuppetNetworkManagerModule#24 by kbucheli), the sections are prepared by `networkmanager::prepare_ipv4_config` and `networkmanager::prepare_ipv6_config`
    - `networkmanager::ifc::bridge` ignored `$ipv4_dns`, it is written now
    - the `hash2stuff` dependency was removed (jednoprsak/PuppetNetworkManagerModule#30), the keyfiles and `NetworkManager.conf` are rendered by the bundled `templates/ini.epp`
    - the unused `NMMod::*` types and the unused `networkmanager::get_ipv6_duid` function were removed
* New features:
    - `$networkmanager::ipv6_dhcp_duid_default` (`'auto'` by default) is used for the connections that do not set their own `$ipv6_dhcp_duid`, so a connection with the `$mac_address` does not need `$ipv6_dhcp_duid => 'auto'` any more (it failed to compile before); the value `'unset'` (for the class and for a connection) does not write the DUID so NetworkManager uses its own default; a connection with the `auto` DUID and without the `$mac_address` still fails, with a message that points to the ways out (jednoprsak/PuppetNetworkManagerModule#29); the DUID is resolved by `networkmanager::resolve_ipv6_duid`
    - an ethernet `networkmanager::ifc::connection` without `$interface_name` and `$mac_address` uses its title as the interface name (it failed to compile before), a title which can not be an interface name fails with a clear message (jednoprsak/PuppetNetworkManagerModule#31)
    - `$ipv4_address` and `$ipv6_address` accept more addresses as an array or as a string separated by a semicolon, they are written as `address1`, `address2`, ... (a single address is still written as `address`), verified with NetworkManager from 1.10.12 to 1.54 (jednoprsak/PuppetNetworkManagerModule#33)
    - `$ipv4_dns` and `$ipv6_dns` accept also an array of up to 5 addresses (validated by the `stdlib` IP address types), the semicolon separated string is still accepted and may contain compressed IPv6 addresses
    - [OpenVox](https://voxpupuli.org/openvox/) 7 and 8 are supported and tested in the CI (`OPENVOX_GEM_VERSION` selects it in the `Gemfile`)
    - supported: `puppet` `>= 4.9.2 < 9.0.0` and `puppetlabs/stdlib` `>= 5.2.0 < 11.0.0` (verified against the individual releases); operating systems AlmaLinux, Amazon Linux, Arch Linux, CentOS, Debian, Fedora, Gentoo, Manjaro, Oracle Linux, RedHat, Rocky and Ubuntu (jednoprsak/PuppetNetworkManagerModule#30)
    - `REFERENCE.md` describes the classes, defined types, functions, data types and the fact
* Fixes:
    - `networkmanager::ifc::connection`, `::bond`, `::bridge` and `::vlan` build their keyfile through the new `networkmanager::compact_keyfile` function, the generated files are unchanged
    - `vlan_parent` is a managed connection `$id` or a plain UUID (NetworkManager does not accept any prefix like `UUID=`), documented and tested; the parent interface name is deliberately not supported (jednoprsak/PuppetNetworkManagerModule#34)
    - the example in the README used a connection id shorter than the 3 characters required, an invalid DUID and had missing commas, it compiles now (jednoprsak/PuppetNetworkManagerModule#32)
    - the error for an unsupported OS family names the family instead of the garbled message
    - `networkmanager::ipv6_disable_version` does not fail before NetworkManager is installed (the fact is missing then)
    - typos in the documentation, the comments and the messages
* Maintenance:
    - the spec tests were rewritten to run against every operating system release listed in `metadata.json`, a GitHub Actions workflow runs the metadata, syntax and lint checks and the specs on Puppet 6, 7 and 8 and OpenVox 7 and 8
    - the parameters of the classes and defined types are documented in the `@param` format and the lint has no warnings
    - the PDK leftovers (Travis, GitLab and AppVeyor configs, `.rubocop.yml`, `.sync.yml`, `pdk.yaml`, `.yardopts`, `.pdkignore`, the dev container and VS Code settings, the `pdk-*` and `template-*` keys of `metadata.json`) were removed and the `Rakefile` was reduced to the tasks used by the tests

## any -> 1.0.0-rc1
* Breaking changes:
    - the `$ifc_name` parameter was renamed to `$interface_name`
    - connection `$id` is by default limited to 3 to 15 characters, because it is used as the default value of `$interface_name`, which is limited to a maximum of 15 characters by the kernel. You can change this behaviour by adjusting `$networkmanager::max_length_of_connection_id`, then you need to supply the `$interface_name` where applicable if you use `$id` longer than 15 characters
    - The parameters got their limits adjusted so they expect the right types (eg. `$vlan_id` was accepted as a string before, now it must be an integer from 1 to 4094 inclusive). The changes are almost everywhere, so check your code (it will just fail to compile)

* New features:
    - added the untested support for Debian
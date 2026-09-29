# CHANGELOG
## 1.0.0-rc1 -> 1.1.0
* Changes:
    - the `hash2stuff` dependency was removed, the keyfiles and `NetworkManager.conf` are now rendered by the bundled `templates/ini.epp`
    - `networkmanager::ifc::connection`, `::bond`, `::bridge` and `::vlan` build their keyfile through the new `networkmanager::compact_keyfile` function, the generated files are unchanged (except for the fix below)
    - compilation fails when `$ipv6_dhcp_duid` is `'auto'` and `$mac_address` is not set
    - [OpenVox](https://voxpupuli.org/openvox/) 7 and 8 are supported and tested in the CI (`OPENVOX_GEM_VERSION` selects it in the `Gemfile`)
    - the supported `puppet` (`>= 4.9.2 < 9.0.0`) and `puppetlabs/stdlib` (`>= 5.2.0 < 11.0.0`) version ranges were verified against the individual releases
    - extended the list of supported operating systems (AlmaLinux, Amazon Linux, Arch Linux, CentOS, Debian, Fedora, Gentoo, Manjaro, Oracle Linux, RedHat, Rocky, Ubuntu)
    - documented that `vlan_parent` is a managed connection `$id` or a plain UUID (the parent interface name is not supported), with tests
    - the parameters of the classes and defined types are documented in the `@param` format (`puppet-lint` `parameter_documentation`), the CI lint has no warnings, the unused `networkmanager::get_ipv6_duid` was removed and `networkmanager::ipv6_disable_version` does not fail before NetworkManager is installed
    - added `REFERENCE.md` and corrected the parameter documentation of the connection defines
    - the unused `NMMod::*` types were removed
    - the PDK leftovers (Travis, GitLab and AppVeyor configs, `.rubocop.yml`, `.sync.yml`, `pdk.yaml`, `.yardopts`, `.pdkignore`, the dev container and VS Code settings, the `pdk-*` and `template-*` keys of `metadata.json`) were removed and the `Rakefile` was reduced to the tasks used by the tests
    - the spec tests were rewritten to run against every operating system release listed in `metadata.json` and a GitHub Actions workflow runs them on Puppet 6, 7 and 8

* New features:
    - the new `$networkmanager::ipv6_dhcp_duid_default` (`'auto'` by default) is used for the connections that do not set their own `$ipv6_dhcp_duid`, a connection with the `$mac_address` therefore does not need `$ipv6_dhcp_duid => 'auto'` any more (it failed to compile before), the value `'unset'` (for the class and for a connection) does not write the DUID at all so NetworkManager uses its own default; the DUID is resolved by `networkmanager::resolve_ipv6_duid`
    - `$ipv6_dhcp_duid` of `connection`, `bond` and `bridge` is validated by the `Networkmanager::DHCP_DUID` type (the `connection` accepted any string before)
    - an ethernet `networkmanager::ifc::connection` without `$interface_name` and `$mac_address` uses its title as the interface name (it failed to compile before), a title which can not be an interface name fails with a clear message
    - only the `method` is written to the `ipv4` section when it is `disabled` and to the `ipv6` section when it is `ignore` or `disabled`, the other settings have no effect there (based on the pull request 24 by kbucheli), the settings are prepared by `networkmanager::prepare_ipv4_config` and `networkmanager::prepare_ipv6_config`
    - `$ipv4_address` and `$ipv6_address` accept more addresses as an array or as a string separated by a semicolon, they are written as `address1`, `address2`, ... (a single address is still written as `address`)
    - `$ipv4_dns` and `$ipv6_dns` accept also an array of up to 5 addresses (validated by the `stdlib` IP address types), the semicolon separated string is still accepted, `$ipv6_dns` strings may now contain compressed IPv6 addresses

* Fixes:
    - the example in the README used a connection id shorter than the 3 characters required, an invalid DUID and had missing commas, it compiles now
    - the error for an unsupported OS family names the family instead of the garbled message
    - the keyfile values are now formatted by `networkmanager::ini_value` according to the GLib key file rules: arrays are written as `a;b;` (they were rendered as `[a, b]`), the backslash, new line, tab, carriage return and edge spaces are escaped so a value can not break the file
    - the `Networkmanager::DNS_IPV4`, `DNS_IPV6` and `IPV4_CIDR` types used unanchored patterns and accepted almost any string, they now validate the whole value
    - `networkmanager::ifc::bridge` ignored `$ipv4_dns`

## any -> 1.0.0-rc1
* Breaking changes:
    - the `$ifc_name` parameter was renamed to `$interface_name`
    - connection `$id` is by default limited to 3 to 15 characters, because it is used as the default value of `$interface_name`, which is limited to a maximum of 15 characters by the kernel. You can change this behaviour by adjusting `$networkmanager::max_length_of_connection_id`, then you need to supply the `$interface_name` where applicable if you use `$id` longer than 15 characters
    - The parameters got their limits adjusted so they expect the right types (eg. `$vlan_id` was accepted as a string before, now it must be an integer from 1 to 4094 inclusive). The changes are almost everywhere, so check your code (it will just fail to compile)

* New features:
    - added the untested support for Debian
# networkmanager


## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with networkmanager](#setup)
    * [What networkmanager module affects](#what-networkmanager-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with networkmanager](#beginning-with-networkmanager)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Development - Guide for contributing to the module](#development)

## Description

You want to use our module because noone written another module for using keyfiles yet (October 18, 2022) and we from Prague Academy of Physics computing farm geeks are the best underground team ever, but stop flexing. I hope that this module will be usable for you. The module installs NetworkManager, configures its config file, starts service, creates keyfiles and pushes them inside NetworkManager via nmcli(and nmcli pushes them inside via dbus). It provides a few defined resources to create keyfiles for connnection(dhcp, static, ipv6, ipv4), bridge, bond, vlan and fallback defined resource for user defined keyfile.


## Setup

### What networkmanager module affects **OPTIONAL**

Brain and mood.

### Setup Requirements **OPTIONAL**

You need a few additional libraries like hash2stuff.

### Beginning with networkmanager

When you want to begin with NetworkManager, you need to be clever as devil, but 
our module will help you create keyfiles and push them inside that oven of hell.

## Usage

class { 'networkmanager':
  erase_unmanaged_keyfiles => true,
  no_auto_default          => true;
}

networkmanager::ifc::connection { 'z1':
  ensure         => present,
  mac_address    => '52:54:00:4d:2a:56',
  ipv4_method    => 'manual',
  ipv4_address   => '192.168.1.12/24,192.168.1.1',
  ipv4_dns       => '8.8.8.8;8.8.4.4;',
  ipv6_method    => 'manual',
  ipv6_dhcp_duid => '00:22:66::52:54:10:44:2a:56'
  ipv6_address   => 'IPV6ADDRESS/PREFIX',
  ipv6_dns       => 'IPV6DNS1;IPV6DNS2;'
  ipv6_gateway   => 'IPV6GATEWAY'
}

networkmanager::ifc::bridge { 'bridge1':
  ensure => present,
  type => 'bridge',
  ipv6_method => 'disabled',
}

networkmanager::ifc::bridge::slave { 'bridge1-slave':
  ensure => present,
  mac_address  => 'MM:AA:CC:MM:AA:CC', #here insert MAC address string.
  master     => 'bridge1',
  slave_type => 'bridge'
}

networkmanager::ifc::bond { 'bondmaster2':
  ensure => present,
  ipv4_method => 'auto',
  ipv6_method => 'ignore',
  additional_config => {
    bond => {
      mode => 'balance-xor',
      miimon => '100',
    }
  };
}

networkmanager::ifc::bond::slave { 'bondslaveens8':
  ensure => present,
  mac_address => 'MAC_ADDRESS',
  master  => 'bondmaster2',
}
  
networkmanager::ifc::bond::slave { 'bondslaveens9':
  ensure => present,
  mac_address => 'MAC_ADDRESS',
  master  => 'bondmaster2',
}


## Contact

mica@fzu.cz
jednoprsak@gmail.com

## Development

In the Development section, tell other users the ground rules for contributing
to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You can also add any additional sections you feel are
necessary or important to include here. Please use the `##` header.


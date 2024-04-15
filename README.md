# networkmanager


## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with networkmanager](#setup)
    * [What networkmanager module affects](#what-networkmanager-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with networkmanager](#beginning-with-networkmanager)

## Description

You want to use our module because noone written another module for using keyfiles yet (October 18, 2022) and we from Prague Academy of Physics computing farm geeks are the best underground team ever, but stop flexing. I hope that this module will be usable for you. The module installs NetworkManager, configures its config file, starts service, creates keyfiles and pushes them inside NetworkManager via nmcli(and nmcli pushes them inside via dbus). It provides a few defined resources to create keyfiles for connnection(dhcp, static, ipv6, ipv4), bridge, bond, vlan and fallback defined resource for user defined keyfile.


## Setup

### What networkmanager module affects **OPTIONAL**

Brain and mood.

### Setup Requirements **OPTIONAL**

You need a few additional libraries:
* hash2stuff
* sdtlib

### Beginning with networkmanager

When you want to begin with NetworkManager, you need to be clever as devil, but
our module will help you create keyfiles and push them inside that oven of hell.

## Usage
```puppet

class {
  'networkmanager':
    erase_unmanaged_keyfiles => true,
    no_auto_default          => true;
}

networkmanager::ifc::connection {
  'z1':
    ensure         => present,
    mac_address    => '52:54:00:4d:2a:56',
    ipv4_method    => 'manual',
    ipv4_address   => '192.168.1.12/24,192.168.1.1',
    ipv4_dns       => '8.8.8.8;8.8.4.4;',
    ipv6_method    => 'manual',
    ipv6_dhcp_duid => '00:22:66::52:54:10:44:2a:56'
    ipv6_address   => 'IPV6ADDRESS/PREFIX',
    ipv6_dns       => 'IPV6DNS1;IPV6DNS2;'
    ipv6_gateway   => 'IPV6GATEWAY';
}

networkmanager::ifc::bridge {
  'bridge1':
    ensure      => present,
    ipv6_method => 'ignore';
}

networkmanager::ifc::bridge::slave {
  'bridge1-slave':
    ensure      => present,
    mac_address => 'MM:AA:CC:MM:AA:CC', #here insert MAC address string.
    master      => 'bridge1';
}

networkmanager::ifc::bond {
  'bondmaster2':
    ensure            => present,
    ipv4_method       => 'auto',
    ipv6_method       => 'ignore',
    bond_mode         => 'balance-xor'
    additional_config => {
      bond => {
        miimon => '100',
      }
    };
}

networkmanager::ifc::bond::slave {
  'bondslaveens8':
    ensure      => present,
    mac_address => 'MAC_ADDRESS',
    master      => 'bondmaster2';
}

networkmanager::ifc::bond::slave {
  'bondslaveens9':
    ensure      => present,
    mac_address => 'MAC_ADDRESS',
    master      => 'bondmaster2';
}
```

## Connection id length
The `connection.id` parametre is limited by deafult to 15 charactes, because is by deafult used also as the interface name.
The interface name has upper limit of 15 characters set by kernel.
You can override this limit by setting the $networkmanager::max_length_of_connection_id to the value you like but then you need to set, where applicable, the `connection.interface-name` to something what is less than 16 characters long.

## Contact

mica@fzu.cz
jednoprsak@gmail.com


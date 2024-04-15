# CHANGELOG
## any -> 1.0.0-rc1
* Breaking changes:
    - the $ifc_name parametre was renamed to $interface_name
    - connection $id is by default limited to 3 to 15 characters to comply with the usage of this as deafult a value for the $interface_name which is limited to maximum of 15 character by the kernel you can change this behaviour by adjusting the $networkmanager::max_length_of_connection_id, then you need to supply the $iterface_name where applicable if you use $id > 15 characters
    - The parametres got their limits adjusted so it will expect right types (eg. $vlan_id was accepted as string before, now it must be integer of 1 to 4095 including), the chages are almost everywhere so check your code (it will just fail to compile)

* New features:
    - added the untested support for the Debian
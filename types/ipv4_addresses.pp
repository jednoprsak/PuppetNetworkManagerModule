# One or more IPv4 addresses with the prefix length (eg. '192.168.1.12/24', optionally followed by the gateway),
# as an array or as a string with the addresses separated by a semicolon (eg. '192.168.1.12/24;192.168.2.12/24')
type Networkmanager::IPV4_ADDRESSES = Variant[
  Networkmanager::IPV4_CIDR,
  Array[Networkmanager::IPV4_CIDR, 1],
  Pattern[/\A(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}\/([12]?[0-9]|3[0-2])(;(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}\/([12]?[0-9]|3[0-2]))+;?\z/],
]

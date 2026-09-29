# Up to 5 IPv4 DNS server addresses, either as an array of addresses (eg. ['8.8.8.8', '8.8.4.4'])
# or as the keyfile string with the addresses separated by a semicolon (eg. '8.8.8.8;8.8.4.4;')
type Networkmanager::DNS_IPV4 = Variant[
  Pattern[/\A(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}(;(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}){0,4};?\z/],
  Array[Stdlib::IP::Address::V4::Nosubnet, 1, 5],
]

# One or more IPv6 addresses with the prefix length (eg. '2001:db8::5/64'),
# as an array or as a string with the addresses separated by a semicolon (eg. '2001:db8::5/64;2001:db8:1::5/64')
type Networkmanager::IPV6_ADDRESSES = Variant[
  Stdlib::IP::Address::V6::CIDR,
  Array[Stdlib::IP::Address::V6::CIDR, 1],
  Pattern[/\A[[:xdigit:]:.]+\/[0-9]{1,3}(;[[:xdigit:]:.]+\/[0-9]{1,3})+;?\z/],
]

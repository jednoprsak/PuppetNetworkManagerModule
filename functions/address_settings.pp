# Returns the keyfile settings with the IP addresses of the connection: a single address is written as `address`,
# more addresses as `address1`, `address2` and so on (the format used by NetworkManager itself).
# The addresses can be given as an array or as a string with the addresses separated by a semicolon.
# Parameters:
#   $addresses = the address (with the prefix length) or the addresses, undef returns no settings

function networkmanager::address_settings(
  Optional[Variant[String, Array[String]]] $addresses,
) >> Hash {
  $list = $addresses ? {
    Array   => $addresses,
    String  => split($addresses, ';').filter |$address| { '' != $address },
    default => [],
  }
  $count = $list ? {
    Array[String, 0, 0] => 0,
    Array[String, 1, 1] => 1,
    default             => 2,
  }
  if 0 == $count {
    $result = {}
  }
  elsif 1 == $count {
    $result = { 'address' => $list[0] }
  }
  else {
    $result = Hash($list.map |$index, $address| { ["address${$index + 1}", $address] })
  }
  $result
}

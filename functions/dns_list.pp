# Converts the DNS servers to the string used by the keyfile: the addresses separated and terminated by a semicolon.
# The string (the legacy format) and undef are returned unchanged.
# Parameters:
#   $dns = array of DNS server addresses or already formatted string

function networkmanager::dns_list(
  Optional[Variant[String, Array[String]]] $dns,
) >> Optional[String] {
  $dns ? {
    Array   => "${join($dns, ';')};",
    default => $dns,
  }
}

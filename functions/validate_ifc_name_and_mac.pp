# Validates that the connection has at least one of 'mac address' or 'interface name' supplied
# Parameters:
#   $caller = the puppet name of the resource which called this function (for sensible error line)
#   $caller_title = the instance of the resource which called the function (for sensible error line)
#   $interface_mac = the connection interface mac address
#   $ine4terface_name = the connection interface name

function networkmanager::validate_ifc_name_and_mac (
  String                        $caller,
  String                        $caller_title,
  Variant[Undef, Stdlib::MAC]   $interface_mac,
  Variant[Undef, String[3, 15]] $interface_name,
) >> Hash {
  if !($interface_mac or $interface_name) {
    fail("You need to provide either mac address or interface name for ${caller}(${$caller_title})")
  }

  networkmanager::compact_keyfile({
    'ethernet'   => { 'mac-address' => $interface_mac },
    'connection' => { 'interface-name' => $interface_name },
  })
}

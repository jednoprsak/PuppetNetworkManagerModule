# Validates thet the connection has at least one of 'mac address' or 'interface name' supplied
# Parametres:
#   $caller = the puppet name of the resource which called this function (for sensible error line)
#   $caller_title = the instance of the resouce which alled the fumction (for sensible error line)
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

  if $interface_mac {
    $mac_config = {
      ethernet => {
        mac-address => $interface_mac,
      }
    }
  }
  else {
    $mac_config = {}
  }

  if $interface_name {
    $interface_config = {
      connection => {
        interface-name => $interface_name
      }
    }
  }
  else {
    $interface_config = {}
  }
  deep_merge($mac_config, $interface_config)
}

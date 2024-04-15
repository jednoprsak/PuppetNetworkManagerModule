# Retunrs IPv6 DHCP DUID
# Parametres:
#   $mac = MAC address of the interface
# Additional variables:
#   $networkmanager::duid_prefix = prefix for the dhcp duid (taken from the networkmanager class)

function networkmanager::connection_duid(
  Stdlib::MAC $mac,
) >> String {
  $mac_d = downcase($mac)
  "${networkmanager::duid_prefix_d}:${mac_d}"
}

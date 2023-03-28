function networkmanager::connection_duid(Stdlib::MAC $mac,) >> String{
  $mac_d = downcase($mac)
  "00:03:00:01:${mac_d}"
}

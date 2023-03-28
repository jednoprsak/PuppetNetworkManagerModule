function networkmanager::ipv6_disable_version(
  String $ipv6_method
) >> String
{
  if (
    $ipv6_method == 'disabled'
      and
    Integer($facts['networkmanager']['version']['major']) == 1
      and
    Integer($facts['networkmanager']['version']['minor']) < 20
  )
  {
    include networkmanager::notify_ipv6_disabled
    $return = 'ignore'
  }
  else {
    $return = $ipv6_method
  }
  $return
}

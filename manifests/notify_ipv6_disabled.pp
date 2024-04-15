# To be included from networkmanager::ipv6_disable_version
# when incompatible $ipv6_method is detected to inform the user

class networkmanager::notify_ipv6_disabled {
  $text = '"disabled" option for parameter ipv6_method is not available in versions of network manager minor than 1.20, changing to "ignore"'
  notify {$text:;}
  warning($text)
}

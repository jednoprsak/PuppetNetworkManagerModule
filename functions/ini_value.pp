# Formats a value for the NetworkManager keyfile (GLib key file format): the values are not quoted,
# the backslash, the new line, the tab, the carriage return and the leading or trailing space are escaped
# and an array is written as the list of values terminated by a semicolon (eg. 'a;b;').
# A string is only escaped, so an already formatted list (eg. '192.0.2.53;') is left as it is.
# Parameters:
#   $value = the value to format (string, number, boolean, undef or an array of them)

function networkmanager::ini_value(
  Variant[Undef, Boolean, Numeric, String, Array[Variant[Boolean, Numeric, String]]] $value,
) >> String {
  case $value {
    Undef:   { '' }
    Array:   {
      $items = $value.map |$item| {
        regsubst(networkmanager::ini_value(String($item)), ';', '\\\;', 'G')
      }
      empty($items) ? {
        true    => '',
        default => "${join($items, ';')};",
      }
    }
    default: {
      $backslash = regsubst(String($value), '\\\\', '\\\\\\\\', 'G')
      $newline   = regsubst($backslash, /\n/, '\\\\n', 'G')
      $tab       = regsubst($newline, /\t/, '\\\\t', 'G')
      $return    = regsubst($tab, /\r/, '\\\\r', 'G')
      $leading   = regsubst($return, '\A ', '\\\\s')
      regsubst($leading, ' \z', '\\\\s')
    }
  }
}

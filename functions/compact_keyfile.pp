# Removes the undefined settings and the empty sections from a keyfile hash, so the caller
# can list every optional setting in one literal instead of building it up conditionally.
# Parameters:
#   $sections = hash of sections, each one a hash of settings (undef values are dropped)

function networkmanager::compact_keyfile(
  Hash[String, Hash] $sections,
) >> Hash {
  $sections.reduce({}) |$memo, $section| {
    $settings = $section[1].filter |$key, $value| { undef != $value }
    if {} == $settings {
      $memo
    }
    else {
      $memo + { $section[0] => $settings }
    }
  }
}

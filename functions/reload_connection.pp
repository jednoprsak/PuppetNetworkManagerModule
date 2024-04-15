# Reloads the connection through the dbus
# Parametres:
#   $uuid = the connection uuid
#   $state = the disered connection state

function networkmanager::reload_connection(
  Pattern[/^\h{8}-(\h{4}-){3}\h{12}$/] $uuid,
  Enum['up', 'down'] $state,
) >> String {
  $bash_part = 'while test "$(gdbus introspect --system --dest org.freedesktop.NetworkManager --object-path /org/freedesktop/NetworkManager/Settings| wc -l)" -lt "3"; do sleep 1 ; done && /usr/bin/nmcli connection reload && /usr/bin/nmcli connection'
  "${bash_part} ${state} ${uuid}"
}

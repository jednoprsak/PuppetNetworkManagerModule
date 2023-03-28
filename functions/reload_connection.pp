function networkmanager::reload_connection(
             String $id,
             String $state
) >> String {
$bash_part = 'while test "$(gdbus introspect --system --dest org.freedesktop.NetworkManager --object-path /org/freedesktop/NetworkManager/Settings| wc -l)" -lt "3"; do sleep 1 ; done && /usr/bin/nmcli connection reload && /usr/bin/nmcli connection'
$values_part = "${state} ${id}"
"${bash_part} ${values_part}"
}



#'while test "$(gdbus introspect --system --dest org.freedesktop.NetworkManager --object-path /org/freedesktop/NetworkManager/Settings| wc -l)" -lt "3"; do sleep 1 ; done ; /usr/bin/nmcli connection reload && /usr/bin/nmcli connection ${state} ${id}'


#"/usr/bin/sleep 2 && /usr/bin/nmcli connection reload && /usr/bin/nmcli connection ${state} ${id}"

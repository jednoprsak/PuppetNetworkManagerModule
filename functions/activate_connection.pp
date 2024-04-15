# Activates the connection after configuration
# parametres:
#   $uuid  = uuid of the connection as genereated by networkmanager::connection_uuid function or supplied by user
#   $id    = name of the connection (here userd for a file name)
#   $state = the connection state
# Additional variables:
#   $networkmanager::sys_id = system name

function networkmanager::activate_connection (
  Pattern[/^\h{8}-(\h{4}-){3}\h{12}$/] $uuid,
  String[3] $id,
  Enum['up', 'down'] $state,
){
  if $state == 'up' {
    @@exec {
      "activate connection after initial config ${uuid}":
          command     => networkmanager::reload_connection($uuid, $state),
          provider    => 'shell',
          group       => 'root',
          user        => 'root',
          subscribe   => File["/etc/NetworkManager/system-connections/${id}.nmconnection"],
          refreshonly => true,
          tag         => "nmactivate-2022b07${networkmanager::sys_id}";
      "activate connectian always ${uuid}":
          command  => networkmanager::reload_connection($uuid, $state),
          provider => 'shell',
          group    => 'root',
          user     => 'root',
          unless   => "/usr/bin/nmcli -t -f GENERAL con show ${uuid} | /usr/bin/grep 'GENERAL.STATE:activated'",
          require  => Exec["activate connection after initial config ${uuid}"],
          tag      => "nmactivate-2022b07${networkmanager::sys_id}";
    }
  } elsif $state == 'down' {
    @@exec {
      "deactivate connection ${uuid}":
        command   => networkmanager::reload_connection($uuid, $state),
        provider  => 'shell',
        group     => 'root',
        user      => 'root',
        subscribe => File["/etc/NetworkManager/system-connections/${id}.nmconnection"],
        onlyif    => "/usr/bin/nmcli -t -f GENERAL con show ${uuid} | /usr/bin/grep 'GENERAL.STATE:activated'",
        tag       => "nmactivate-2022b07${networkmanager::sys_id}";
    }
  }
}

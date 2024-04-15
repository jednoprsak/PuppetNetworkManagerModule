# Returns stable connection uuid unless connection $id is uuid already.
# Parametres:
#   $id = connection id

function networkmanager::connection_uuid(
  String $id,
) >> String {
  if $id =~ /^\h{8}-(\h{4}-){3}\h{12}$/ {
    $id
  }
  else {
    fqdn_uuid("${networkmanager::sys_id}${id}sPubI8dBBZgpiY9j5OwJpF")
  }
}

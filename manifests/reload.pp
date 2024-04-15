# This class is used to collect different keyfile activation exported resources and apply them.
# Not to be used by user

class networkmanager::reload {
  Exec <<| tag == "nmactivate-2022b07${networkmanager::sys_id}" |>>
}

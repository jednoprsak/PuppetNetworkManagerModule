# @summary A short summary of the purpose of this class
#
# A description of what this class does
# This class is used to collect different keyfile activation exported resources and apply them.
#
class networkmanager::reload {
  Exec <<| tag == "nmactivate-2022b07${networkmanager::sys_id}" |>>
}

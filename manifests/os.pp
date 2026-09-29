# This class sets the OS specific variables (package names) of the networkmanager module.
# Not to be used by user
#
# @summary OS specific variables for the networkmanager module
class networkmanager::os () {
  $os_family = downcase($facts['os']['family'])
  case $os_family {
    'archlinux': {
      $package_name = 'networkmanager'
      $extra_packages = []
    }
    'debian': {
      $package_name = 'network-manager'
      $extra_packages = []
    }
    'redhat': {
      $package_name = 'NetworkManager'
      $extra_packages = []
    }
    'gentoo': {
      $package_name = 'net-misc/networkmanager'
      $extra_packages = []
    }
    default: {
      fail("The OS family '${facts['os']['family']}' is not supported by the networkmanager module")
    }
  }
}

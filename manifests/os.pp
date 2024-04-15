# @summary OS specific variables for the networkmanager module
class networkmanager::os (){
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
      fail('OS family id notz defined for the networkmanager module')
    }
  }
}

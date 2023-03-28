# @summary OS specific variables for the networkmanager module
class networkmanager::os (){
  $os_family = downcase($facts['os']['family'])
  case $os_family {
    'archlinux':{
      $package_name = 'networkmanager'
      $extra_packages = []
    }
    'redhat':{
      $package_name = 'NetworkManager'
      $extra_packages = []
    }
    default: {
      fail('OS family unknown')
    }
  }
}

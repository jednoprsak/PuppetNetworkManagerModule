# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include networkmanager::install
class networkmanager::install (
  Boolean          $install_package = $networkmanager::install_package,
  String           $package_name = $networkmanager::os::package_name,
  Array            $extra_packages = $networkmanager::os::extra_packages,
  Boolean          $install_extra_packages = $networkmanager::install_package,
  Optional[String] $version = $networkmanager::version,
) {
  if $version {
    $ensure_nm_install = $version
  }
  elsif !$version {
    $ensure_nm_install = present
  }

  if $install_package {
    package {
      $package_name:
        ensure => $ensure_nm_install;
    }
  }
  if $install_extra_packages and $extra_packages != [] {
    package {
      $extra_packages:
        ensure => present;
    }
  }
}

# === Parameters:
#
#   $install_package - optional - true|false
#   $version         - optional - version string

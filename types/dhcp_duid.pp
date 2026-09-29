# The IPv6 DHCP DUID of a connection: 'auto' builds it from the mac address of the interface (see the duid_prefix of the networkmanager class),
# 'unset' does not write it so NetworkManager uses its own default, the other values are the NetworkManager keywords or a literal DUID (aa:bb:cc:...)
type Networkmanager::DHCP_DUID = Variant[
  Pattern[/\A\h{2}(:\h{2})+\z/],
  Enum['auto', 'unset', 'lease', 'll', 'llt', 'stable-ll', 'stable-llt', 'stable-uuid'],
]

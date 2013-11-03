  url 'http://downloads.sourceforge.net/project/net-snmp/net-snmp/5.7.2/net-snmp-5.7.2.tar.gz'
  sha1 'c493027907f32400648244d81117a126aecd27ee'
    system "./configure", "--disable-debugging",
                          "--prefix=#{prefix}",
                          "--enable-ipv6",
                          "--with-persistent-directory=#{var}/db/net-snmp",
                          "--with-logfile=#{var}/log/snmpd.log",
                          "--without-rpm",
                          "--without-kmem-usage",
                          "--disable-embedded-perl",
                          "--without-perl-modules"
require 'formula'

class CyrusSasl < Formula
  homepage ''
  url 'ftp://ftp.cyrusimap.org/cyrus-sasl/cyrus-sasl-2.1.26.tar.gz'
  version '2.1.26'
  sha1 'd6669fb91434192529bd13ee95737a8a5040241c'

  depends_on 'libopenldap' 

  def install
    inreplace 'Makefile.in', "/Library/Frameworks", "#{prefix}/Library/Frameworks"
    inreplace 'include/Makefile.in', "/Library/Frameworks", "#{prefix}/Library/Frameworks"
    inreplace 'lib/Makefile.in', "/Library/Frameworks", "#{prefix}/Library/Frameworks"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", 
                          "--enable-ldapdb",
                          "--with-ldap=#{Formula.factory('libopenldap').prefix}"
    system "make install" 
  end
end

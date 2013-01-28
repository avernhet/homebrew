require 'formula'

class Libserf < Formula
  url 'http://serf.googlecode.com/files/serf-1.1.0.tar.bz2'
  homepage 'http://code.google.com/p/serf/'
  sha1 '231af70b7567a753b49df4216743010c193884b7'

  depends_on 'gnu-libtool'
  depends_on 'openssl'

  def install
    # Mac OS X APR is built with non-existing tools
    ENV['CPP'] = "llvm-cpp-4.2"
    ENV['APR_LIBTOOL'] = "#{Formula.factory('gnu-libtool').prefix}/bin/libtool"

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-openssl=#{Formula.factory('openssl').prefix}",
                          "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end


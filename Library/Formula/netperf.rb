require 'formula'

class Netperf < Formula
  url 'ftp://ftp.netperf.org//netperf/netperf-2.5.0.tar.bz2'
  homepage 'http://www.netperf.org/netperf/NetperfPage.html'
  md5 'fe23629f061a161b9d52d39b16620318'

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end

end

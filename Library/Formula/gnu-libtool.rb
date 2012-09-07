require 'formula'

class GnuLibtool <Formula
  url 'http://ftp.gnu.org/gnu/libtool/libtool-1.5.26.tar.gz'
  homepage 'http://ftp.gnu.org/gnu/libtool/'
  md5 'aa9c5107f3ec9ef4200eb6556f3b3c29'

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end

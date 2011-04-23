require 'formula'

class Autoconf <Formula
  url 'http://ftp.gnu.org/gnu/autoconf/autoconf-2.66.tar.bz2'
  homepage 'http://www.gnu.org/software/autoconf'
  md5 'd2d22a532ee0e4d6d86a02e6425ecfce'

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end

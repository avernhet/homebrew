require 'formula'

class Automake <Formula
  url 'http://ftp.gnu.org/gnu/automake/automake-1.11.1.tar.bz2'
  homepage 'http://www.gnu.org/software/automake'
  md5 'c2972c4d9b3e29c03d5f2af86249876f'

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end

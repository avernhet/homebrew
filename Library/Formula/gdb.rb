require 'formula'

class Gdb <Formula
  url 'http://ftp.gnu.org/gnu/gdb/gdb-7.5.tar.bz2'
  homepage 'http://www.gnu.org/software/gdb/'
  md5 '24a6779a9fe0260667710de1b082ef61'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'ppl'
  depends_on 'libmpc'

  def install
    system "./configure", "--prefix=#{prefix}",
                "--with-gmp=#{Formula.factory('gmp').prefix}",
                "--with-mpfr=#{Formula.factory('mpfr').prefix}",
                "--with-ppl=#{Formula.factory('ppl').prefix}",
                "--with-mpc=#{Formula.factory('libmpc').prefix}",
                "--without-cloog", "--disable-werror"
    system "make"
    system "make install"
  end
end

require 'formula'

class GdbArmEabi <Formula
  url 'http://ftp.gnu.org/gnu/gdb/gdb-7.3.1.tar.bz2'
  homepage 'http://www.gnu.org/software/gdb/'
  md5 'b89a5fac359c618dda97b88645ceab47'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'ppl'
  depends_on 'libmpc'
  depends_on 'cloog-ppl'

  def install
    system "./configure", "--prefix=#{prefix}", "--target=arm-eabi",
                "--with-gmp=#{Formula.factory('gmp').prefix}",
                "--with-mpfr=#{Formula.factory('mpfr').prefix}",
                "--with-ppl=#{Formula.factory('ppl').prefix}",
                "--with-mpc=#{Formula.factory('libmpc').prefix}",
                "--with-cloog=#{Formula.factory('cloog-ppl').prefix}",
                "--enable-cloog-backend=ppl", "--disable-werror"
    system "make"
    system "make install"
  end
end

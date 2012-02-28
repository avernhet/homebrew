require 'formula'

class Gdb <Formula
  url 'http://ftp.gnu.org/gnu/gdb/gdb-7.4.tar.bz2'
  homepage 'http://www.gnu.org/software/gdb/'
  md5 '95a9a8305fed4d30a30a6dc28ff9d060'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'ppl'
  depends_on 'libmpc'
  # depends_on 'cloog' # ./configure does not support CLooG 0.17

  def install
    system "./configure", "--prefix=#{prefix}",
                "--with-gmp=#{Formula.factory('gmp').prefix}",
                "--with-mpfr=#{Formula.factory('mpfr').prefix}",
                "--with-ppl=#{Formula.factory('ppl').prefix}",
                "--with-mpc=#{Formula.factory('libmpc').prefix}",
                "--without-cloog", "--disable-werror"
                #"--with-cloog=#{Formula.factory('cloog').prefix}",
                #"--enable-cloog-backend=isl", "--disable-werror"
    system "make"
    system "make install"
  end
end

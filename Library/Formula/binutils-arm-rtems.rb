require 'formula'

class BinutilsArmRtems <Formula
  @url='http://ftp.gnu.org/gnu/binutils/binutils-2.20.1.tar.bz2'
  @homepage='http://www.gnu.org/software/binutils/'
  @sha1='fd2ba806e6f3a55cee453cb25c86991b26a75dee'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'ppl'
  depends_on 'cloog-ppl'

  def install
    system "./configure", "--prefix=#{prefix}", "--target=arm-rtems",
                "--disable-shared", "--enable-plugins", "--disable-nls",
                "--with-gmp=#{Formula.factory('gmp').prefix}",
                "--with-mpfr=#{Formula.factory('mpfr').prefix}",
                "--with-ppl=#{Formula.factory('ppl').prefix}",
                "--with-cloog=#{Formula.factory('cloog-ppl').prefix}",
                "--enable-multilibs", "--enable-interwork", "--enable-lto",
                "--disable-werror", "--disable-debug"
    system "make"
    system "make install"
  end
end

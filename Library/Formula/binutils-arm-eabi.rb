require 'formula'

class BinutilsArmEabi <Formula
  url 'http://ftp.gnu.org/gnu/binutils/binutils-2.21.1a.tar.bz2'
  homepage 'http://www.gnu.org/software/binutils/'
  sha1 '525255ca6874b872540c9967a1d26acfbc7c8230'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'ppl'
  depends_on 'cloog-ppl'

  def install
    system "./configure", "--prefix=#{prefix}", "--target=arm-eabi",
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

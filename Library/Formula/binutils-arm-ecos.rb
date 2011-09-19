require 'formula'

class BinutilsArmEcos <Formula
  url 'http://ftp.gnu.org/gnu/binutils/binutils-2.20.1a.tar.bz2'
  homepage 'http://www.gnu.org/software/binutils/'
  sha1 '3f0e3746a15f806a95dd079be2a7f43c17b18818'

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

require 'formula'

class BinutilsArmEcos <Formula
  @url='http://ftp.gnu.org/gnu/binutils/binutils-2.20.tar.bz2'
  @homepage='http://www.gnu.org/software/binutils/'
  @sha1='747e7b4d94bce46587236dc5f428e5b412a590dc'

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
                "--enable-multilibs", "--enable-interwork", "--disable-werror",
                "--disable-debug"
    system "make"
    system "make install"
  end
end

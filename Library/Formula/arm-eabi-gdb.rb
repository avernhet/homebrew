require 'formula'

class ArmEabiGdb <Formula
  url 'http://ftp.gnu.org/gnu/gdb/gdb-7.6.tar.bz2'
  homepage 'http://www.gnu.org/software/gdb/'
  sha1 'b64095579a20e011beeaa5b264fe23a9606ee40f'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'libmpc'

  def install
    system "./configure", "--prefix=#{prefix}", "--target=arm-eabi",
                "--with-gmp=#{Formula.factory('gmp').prefix}",
                "--with-mpfr=#{Formula.factory('mpfr').prefix}",
                "--with-mpc=#{Formula.factory('libmpc').prefix}",
                "--without-cloog",
                "--enable-lto","--disable-werror"
    system "make"
    system "make install"
  end
end

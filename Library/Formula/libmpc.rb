require 'formula'

class Libmpc < Formula
  url 'http://multiprecision.org/mpc/download/mpc-0.9.tar.gz'
  homepage 'http://multiprecision.org'
  md5 '0d6acab8d214bd7d1fbbc593e83dd00d'

  depends_on 'gmp'
  depends_on 'mpfr'

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--with-gmp=#{Formula.factory('gmp').prefix}",
                          "--with-mpfr=#{Formula.factory('mpfr').prefix}"

    system "make install"
  end
end

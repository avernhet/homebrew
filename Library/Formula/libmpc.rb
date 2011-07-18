require 'formula'

class Libmpc < Formula
  url 'http://multiprecision.org/mpc/download/mpc-0.9.tar.gz'
  homepage 'http://multiprecision.org'
  sha1 '229722d553030734d49731844abfef7617b64f1a'

  depends_on 'gmp'
  depends_on 'mpfr'

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--with-gmp=#{Formula.factory('gmp').prefix}",
                          "--with-mpfr=#{Formula.factory('mpfr').prefix}"

    system "make install"
  end
end

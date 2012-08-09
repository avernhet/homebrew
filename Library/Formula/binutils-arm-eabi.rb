require 'formula'

class BinutilsArmEabi <Formula
  url 'http://ftp.gnu.org/gnu/binutils/binutils-2.22.tar.bz2'
  homepage 'http://www.gnu.org/software/binutils/'
  sha1 '65b304a0b9a53a686ce50a01173d1f40f8efe404'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'ppl'
  depends_on 'cloog'

  def patches
    # discard PPL version test, as binutils 2.22 expect 0.11+, not 1.0+
    DATA
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--target=arm-eabi",
                "--disable-shared", "--disable-nls",
                "--with-gmp=#{Formula.factory('gmp').prefix}",
                "--with-mpfr=#{Formula.factory('mpfr').prefix}",
                "--with-ppl=#{Formula.factory('ppl').prefix}",
                "--with-cloog=#{Formula.factory('cloog').prefix}",
                "--enable-cloog-backend=isl",
                "--disable-cloog-version-check",
                "--enable-multilibs", "--enable-interwork", "--enable-lto",
                "--disable-werror", "--disable-debug"
    system "make"
    system "make install"
  end
end

__END__
--- a/configure	2012-08-09 22:02:06.000000000 +0200
+++ b/configure	2012-08-09 22:06:14.000000000 +0200
@@ -5662,12 +5662,6 @@
 int
 main ()
 {
-
-    #if PPL_VERSION_MAJOR != 0 || PPL_VERSION_MINOR < 11
-    choke me
-    #endif
-
-  ;
   return 0;
 }
 _ACEOF

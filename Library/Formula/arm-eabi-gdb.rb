require 'formula'

class ArmEabiGdb <Formula
  url 'http://ftp.gnu.org/gnu/gdb/gdb-7.5.tar.bz2'
  homepage 'http://www.gnu.org/software/gdb/'
  md5 '24a6779a9fe0260667710de1b082ef61'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'libmpc'
  #depends_on 'ppl'
  #depends_on 'cloog'

  def patches
    DATA
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--target=arm-eabi",
                "--with-gmp=#{Formula.factory('gmp').prefix}",
                "--with-mpfr=#{Formula.factory('mpfr').prefix}",
                "--with-mpc=#{Formula.factory('libmpc').prefix}",
                #"--with-ppl=#{Formula.factory('ppl').prefix}",
                #"--with-cloog=#{Formula.factory('cloog').prefix}",
                #"--enable-cloog-backend=isl",
                "--without-cloog",
                "--enable-lto","--disable-werror"
    system "make"
    system "make install"
  end
end

__END__
--- a/sim/arm/armsupp.c 2012-09-02 12:35:05.000000000 +0200
+++ b/sim/arm/armsupp.c        2012-09-02 12:34:09.000000000 +0200
@@ -636,7 +636,7 @@
   if (! CP_ACCESS_ALLOWED (state, CPNum))
     {
       ARMul_UndefInstr (state, instr);
-      return;
+      return (0);
     }
 
   cpab = (state->MRC[CPNum]) (state, ARMul_FIRST, instr, &result);

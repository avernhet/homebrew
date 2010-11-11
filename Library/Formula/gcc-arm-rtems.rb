require 'formula'

class GccArmRtems <Formula
  # this is gcc-core-4.5.0 + gcc-g++-4.5.0 + newlib-1.18.0b repackaged as
  # homebrew makes things really hard when it comes to building from a
  # combination of various archives
  @url='http://dl.dropbox.com/u/2402907/gcc-ecos-4.5.0.tar.bz2'
  @homepage='http://gcc.gnu.org/'
  @sha1='d1c91852f00fb93263777ba1f71421f12cab58fb'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'libmpc'
  depends_on 'ppl'
  depends_on 'cloog-ppl'
  depends_on 'libelf'
  depends_on 'binutils-arm-ecos'

  def patches
    DATA
  end

  def install
    # Cannot build with LLVM (cross compiler crashes)
    ENV.gcc_4_2
    # Fix up CFLAGS for cross compilation (default switches cause build issues)
    ENV['CFLAGS_FOR_BUILD'] = "-O2"
    ENV['CFLAGS'] = "-O2"
    ENV['CFLAGS_FOR_TARGET'] = "-O2"
    ENV['CXXFLAGS_FOR_BUILD'] = "-O2"
    ENV['CXXFLAGS'] = "-O2"
    ENV['CXXFLAGS_FOR_TARGET'] = "-O2"

    build_dir='build'
    mkdir build_dir
    Dir.chdir build_dir do
      system "../configure", "--prefix=#{prefix}", "--target=arm-rtems",
                  "--disable-shared", "--with-gnu-as", "--with-gnu-ld",
                  "--with-newlib", "--enable-softfloat", "--disable-bigendian",
                  "--disable-fpu", "--disable-underscore", "--enable-multilibs",
                  "--with-float=soft", "--enable-interwork", "--enable-lto",
                  "--with-multilib-list=interwork", "--with-abi=aapcs",
                  "--enable-languages=c,c++", "--enable-threads=rtems",
                  "--with-gmp=#{Formula.factory('gmp').prefix}",
                  "--with-mpfr=#{Formula.factory('mpfr').prefix}",
                  "--with-mpc=#{Formula.factory('libmpc').prefix}",
                  "--with-ppl=#{Formula.factory('ppl').prefix}",
                  "--with-cloog=#{Formula.factory('cloog-ppl').prefix}",
                  "--with-libelf=#{Formula.factory('libelf').prefix}",
                  "--disable-debug"
      system "make"
      system "make install"
    end

    ln_s "#{Formula.factory('binutils-arm-rtems').prefix}/arm-rtems/bin",
                   "#{prefix}/arm-rtems/bin"
  end
end

__END__
--- a/gcc/config/arm/t-arm-elf	2008-06-12 19:29:47.000000000 +0200
+++ b/gcc/config/arm/t-arm-elf	2010-01-14 00:44:48.000000000 +0100
@@ -40,8 +40,8 @@
 # MULTILIB_DIRNAMES   += fpu soft
 # MULTILIB_EXCEPTIONS += *mthumb/*mhard-float*
 #
-# MULTILIB_OPTIONS    += mno-thumb-interwork/mthumb-interwork
-# MULTILIB_DIRNAMES   += normal interwork
+MULTILIB_OPTIONS    += mno-thumb-interwork/mthumb-interwork
+MULTILIB_DIRNAMES   += normal interwork
 #
 # MULTILIB_OPTIONS    += fno-leading-underscore/fleading-underscore
 # MULTILIB_DIRNAMES   += elf under

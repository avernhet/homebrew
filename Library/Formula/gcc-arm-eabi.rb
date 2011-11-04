require 'formula'

class NewLibArmEabi <Formula
  url       'ftp://sources.redhat.com/pub/newlib/newlib-1.19.0.tar.gz'
  homepage  'http://sourceware.org/newlib/'
  sha1      'b2269d30ce7b93b7c714b90ef2f40221c2df0fcd'
end

class GppArmEabi <Formula
  url       'http://ftpmirror.gnu.org/gcc/gcc-4.6.2/gcc-g++-4.6.2.tar.bz2'
  homepage  'http://gcc.gnu.org/'
  sha1      'f0bc2b4e1c23c5dc1462599efd5df4b9807b23af'
end

class GccArmEabi <Formula
  url       'http://ftpmirror.gnu.org/gcc/gcc-4.6.2/gcc-core-4.6.2.tar.bz2'
  homepage  'http://gcc.gnu.org/'
  sha1      '23d259e2269a40f6e203cf6f57bc7eb7a207a8b3'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'libmpc'
  depends_on 'ppl'
  depends_on 'cloog'
  depends_on 'libelf'
  depends_on 'binutils-arm-eabi'

  def patches
    DATA
  end

  def install
    
    # Ok, I stop fighting against Ruby (wish Homebrew was written in Python...)
    # Use the ditto system command to replicate the directories
    # If anyone knows how to extract an archive into an existing directory
    # with homebrew, please - let me know!
    coredir = Dir.pwd
    GppArmEabi.new.brew { system "ditto", Dir.pwd, coredir }
    NewLibArmEabi.new.brew { 
        system "ditto", Dir.pwd+'/libgloss', coredir+'/libgloss'
        system "ditto", Dir.pwd+'/newlib', coredir+'/newlib' 
    }
    
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
      system "../configure", "--prefix=#{prefix}", "--target=arm-eabi",
                  "--enable-shared", "--with-gnu-as", "--with-gnu-ld",
                  "--with-newlib", "--enable-softfloat", "--disable-bigendian",
                  "--disable-fpu", "--disable-underscore", "--enable-multilibs",
                  "--with-float=soft", "--enable-interwork", "--enable-lto",
                  "--enable-plugin", "--with-multilib-list=interwork", 
                  "--with-abi=aapcs", "--enable-languages=c,c++",
                  "--with-gmp=#{Formula.factory('gmp').prefix}",
                  "--with-mpfr=#{Formula.factory('mpfr').prefix}",
                  "--with-mpc=#{Formula.factory('libmpc').prefix}",
                  "--with-ppl=#{Formula.factory('ppl').prefix}",
                  "--with-cloog=#{Formula.factory('cloog').prefix}",
                  "--enable-cloog-backend=isl",
                  "--with-libelf=#{Formula.factory('libelf').prefix}",
                  "--with-gxx-include-dir=#{prefix}/arm-eabi/include",
                  "--disable-debug", "--disable-__cxa_atexit",
                  "--with-pkgversion=Neotion-SDK-Tylyn",
                  "--with-bugurl=http://www.neotion.com"
      system "make"
      system "make install"
    end

    ln_s "#{Formula.factory('binutils-arm-eabi').prefix}/arm-eabi/bin",
                   "#{prefix}/arm-eabi/bin"
  end
end

__END__
--- a/gcc/config/arm/t-arm-elf	2011-01-03 21:52:22.000000000 +0100
+++ b/gcc/config/arm/t-arm-elf	2011-07-18 16:03:31.000000000 +0200
@@ -71,8 +71,8 @@
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
--- a/gcc/config/i386/i386.c	2011-06-18 11:07:20.000000000 +0200
+++ b/gcc/config/i386/i386.c	2011-07-18 16:03:31.000000000 +0200
@@ -6145,7 +6145,9 @@
    See the x86-64 PS ABI for details.
 */
 
-static int
+int classify_argument (enum machine_mode, const_tree,
+                       enum x86_64_reg_class [MAX_CLASSES], int);
+int
 classify_argument (enum machine_mode mode, const_tree type,
 		   enum x86_64_reg_class classes[MAX_CLASSES], int bit_offset)
 {
@@ -6526,7 +6528,8 @@
 
 /* Examine the argument and return set number of register required in each
    class.  Return 0 iff parameter should be passed in memory.  */
-static int
+int examine_argument (enum machine_mode, const_tree, int, int *, int *);
+int
 examine_argument (enum machine_mode mode, const_tree type, int in_return,
 		  int *int_nregs, int *sse_nregs)
 {

require 'formula'

class ArmEabiNewLib <Formula
  url       'ftp://sourceware.org/pub/newlib/newlib-2.0.0.tar.gz'
  homepage  'http://sourceware.org/newlib/'
  sha1      'ea6b5727162453284791869e905f39fb8fab8d3f'
end

class ArmEabiGcc <Formula
  #url       'http://ftpmirror.gnu.org/gcc/gcc-4.8.0/gcc-4.8.0.tar.bz2'
  url 'file:///Users/eblot/Desktop/gcc-4.8.0.tar.bz2'
  homepage  'http://gcc.gnu.org/'
  sha1      'b4ee6e9bdebc65223f95067d0cc1a634b59dad72'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'libmpc'
  #depends_on 'ppl'
  depends_on 'cloog'
  depends_on 'libelf'
  depends_on 'arm-eabi-binutils'

  def patches
    DATA
  end

  def install

    # Ok, I stop fighting against Ruby (wish Homebrew was written in Python...)
    # Use the ditto system command to replicate the directories
    # If anyone knows how to extract an archive into an existing directory
    # with homebrew, please - let me know!
    coredir = Dir.pwd
    ArmEabiNewLib.new.brew {
        system "ditto", Dir.pwd+'/libgloss', coredir+'/libgloss'
        system "ditto", Dir.pwd+'/newlib', coredir+'/newlib'
    }

    # Fix up CFLAGS for cross compilation (default switches cause build issues)
    ENV['CC'] = "gcc"
    ENV['CXX'] = "gcc"
    ENV['CFLAGS_FOR_BUILD'] = "-O2"
    ENV['CFLAGS'] = "-O2"
    ENV['CFLAGS_FOR_TARGET'] = "-O2"
    ENV['CXXFLAGS_FOR_BUILD'] = "-O2"
    ENV['CXXFLAGS'] = "-O2"
    ENV['CXXFLAGS_FOR_TARGET'] = "-O2"

    # GCC 4.6.x explictly looks for CLooG 0.16, and we use 0.17
    # Hack from http://joelinoff.com/blog/?p=108
    inreplace 'gcc/graphite-clast-to-gimple.c', ' LANGUAGE_C', ' CLOOG_LANGUAGE_C'

    build_dir='build'
    mkdir build_dir
    Dir.chdir build_dir do
      system "../configure", "--prefix=#{prefix}", "--target=arm-eabi",
                  "--disable-shared", "--with-gnu-as", "--with-gnu-ld",
                  "--with-newlib", "--enable-softfloat", "--disable-bigendian",
                  "--disable-fpu", "--disable-underscore", "--enable-multilibs",
                  "--with-float=soft", "--enable-interwork", "--enable-lto",
                  "--with-multilib-list=interwork",
                  "--with-abi=aapcs", "--enable-languages=c,c++",
                  "--with-gmp=#{Formula.factory('gmp').prefix}",
                  "--with-mpfr=#{Formula.factory('mpfr').prefix}",
                  "--with-mpc=#{Formula.factory('libmpc').prefix}",
                  "--with-cloog=#{Formula.factory('cloog').prefix}",
                  "--enable-cloog-backend=isl",
                  "--disable-cloog-version-check",
                  "--with-libelf=#{Formula.factory('libelf').prefix}",
                  "--with-gxx-include-dir=#{prefix}/arm-eabi/include",
                  "--disable-debug", "--disable-__cxa_atexit",
                  "--with-pkgversion=Neotion-SDK2-Celeborn",
                  "--with-bugurl=http://www.neotion.com"
      # Temp. workaround until GCC installation script is fixed
      system "mkdir -p #{prefix}/arm-eabi/lib/fpu/interwork"
      system "make"
      system "make -j1 -k install"
    end

    ln_s "#{Formula.factory('arm-eabi-binutils').prefix}/arm-eabi/bin",
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

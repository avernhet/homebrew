require 'formula'

class ArmEabiNewLib <Formula
  url       'ftp://sourceware.org/pub/newlib/newlib-2.0.0.tar.gz'
  homepage  'http://sourceware.org/newlib/'
  sha1      'ea6b5727162453284791869e905f39fb8fab8d3f'
end

class ArmEabiGcc <Formula
  url       'http://ftpmirror.gnu.org/gcc/gcc-4.8.0/gcc-4.8.0.tar.bz2'
  homepage  'http://gcc.gnu.org/'
  sha1      'b4ee6e9bdebc65223f95067d0cc1a634b59dad72'

  depends_on 'gmp'
  depends_on 'libmpc'
  depends_on 'mpfr'
  depends_on 'cloog'
  depends_on 'isl'
  depends_on 'arm-eabi-binutils'
  depends_on 'gcc48'

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

    gmp = Formula.factory 'gmp'
    mpfr = Formula.factory 'mpfr'
    libmpc = Formula.factory 'libmpc'
    cloog = Formula.factory 'cloog'
    isl = Formula.factory 'isl'
    libelf = Formula.factory 'libelf'
    binutils = Formula.factory 'arm-eabi-binutils'
    gcc48 = Formula.factory 'gcc48'

    # Fix up CFLAGS for cross compilation (default switches cause build issues)
    ENV['CC'] = "#{gcc48.opt_prefix}/bin/gcc-4.8"
    ENV['CXX'] = "#{gcc48.opt_prefix}/bin/g++-4.8"
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
                  "--disable-shared", "--with-gnu-as", "--with-gnu-ld",
                  "--with-newlib", "--enable-softfloat", "--disable-bigendian",
                  "--disable-fpu", "--disable-underscore", "--enable-multilibs",
                  "--with-float=soft", "--enable-interwork", "--enable-lto",
                  "--with-multilib-list=interwork",
                  "--with-abi=aapcs", "--enable-languages=c,c++",
                  "--with-gmp=#{gmp.opt_prefix}",
                  "--with-mpfr=#{mpfr.opt_prefix}",
                  "--with-mpc=#{libmpc.opt_prefix}",
                  "--with-cloog=#{cloog.opt_prefix}",
                  "--enable-cloog-backend=isl",
                  "--with-isl=#{isl.opt_prefix}",
                  "--with-libelf=#{libelf.opt_prefix}",
                  "--with-gxx-include-dir=#{prefix}/arm-eabi/include",
                  "--disable-debug", "--disable-__cxa_atexit",
                  "--with-pkgversion=Neotion-SDK2-Gandalf",
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

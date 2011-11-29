require 'formula'

class Gpp <Formula
  url       'http://ftpmirror.gnu.org/gcc/gcc-4.6.2/gcc-g++-4.6.2.tar.bz2'
  homepage  'http://gcc.gnu.org/'
  sha1      'f0bc2b4e1c23c5dc1462599efd5df4b9807b23af'
end

class Gcc <Formula
  url       'http://ftpmirror.gnu.org/gcc/gcc-4.6.2/gcc-core-4.6.2.tar.bz2'
  homepage  'http://gcc.gnu.org/'
  sha1      '23d259e2269a40f6e203cf6f57bc7eb7a207a8b3'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'libmpc'
  depends_on 'ppl'
  depends_on 'cloog'
  depends_on 'libelf'

  def patches
    DATA
  end

  def install
    
    # Ok, I stop fighting against Ruby (wish Homebrew was written in Python...)
    # Use the ditto system command to replicate the directories
    # If anyone knows how to extract an archive into an existing directory
    # with homebrew, please - let me know!
    coredir = Dir.pwd
    Gpp.new.brew { system "ditto", Dir.pwd, coredir }
    
    # Cannot build with LLVM (cross compiler crashes)
    ENV.gcc_4_2
    # Fix up CFLAGS for cross compilation (default switches cause build issues)
    #ENV['CFLAGS_FOR_BUILD'] = "-O2"
    #ENV['CFLAGS'] = "-O2"
    #ENV['CFLAGS_FOR_TARGET'] = "-O2"
    #ENV['CXXFLAGS_FOR_BUILD'] = "-O2"
    #ENV['CXXFLAGS'] = "-O2"
    #ENV['CXXFLAGS_FOR_TARGET'] = "-O2"

    build_dir='build'
    mkdir build_dir
    Dir.chdir build_dir do
      system "../configure", "--prefix=#{prefix}", 
                  #{ }"--with-gnu-as", "--with-gnu-ld",
                  "--enable-shared", "--enable-lto", "--enable-plugin",  
                  "--enable-languages=c,c++", "--enable-cloog-backend=isl",
                  "--with-gmp=#{Formula.factory('gmp').prefix}",
                  "--with-mpfr=#{Formula.factory('mpfr').prefix}",
                  "--with-mpc=#{Formula.factory('libmpc').prefix}",
                  "--with-ppl=#{Formula.factory('ppl').prefix}",
                  "--with-cloog=#{Formula.factory('cloog').prefix}",
                  "--with-libelf=#{Formula.factory('libelf').prefix}",
                  "--disable-debug"
      system "make"
      system "make install"
    end

    #ln_s "#{Formula.factory('binutils-arm-eabi').prefix}/arm-eabi/bin",
    #              "#{prefix}/arm-eabi/bin"
  end
end

__END__

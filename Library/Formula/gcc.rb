require 'formula'

class Gpp <Formula
  url       'http://ftpmirror.gnu.org/gcc/gcc-4.6.3/gcc-g++-4.6.3.tar.bz2'
  homepage  'http://gcc.gnu.org/'
  sha1      '528d010ee7af50e023bd4d476d65d08df71a7f65'
end

class Gobjc <Formula
  url       'http://ftpmirror.gnu.org/gcc/gcc-4.6.3/gcc-objc-4.6.3.tar.bz2'
  homepage  'http://gcc.gnu.org/'
  sha1      'a584c2b3505a7f6411167027cc7fe473182c6e1c'
end

class Gcc <Formula
  url       'http://ftpmirror.gnu.org/gcc/gcc-4.6.3/gcc-core-4.6.3.tar.bz2'
  homepage  'http://gcc.gnu.org/'
  sha1      'eaefb90df5a833c94560a8dda177bd1e165c2a88'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'libmpc'
  depends_on 'ppl'
  depends_on 'cloog'

  def install
    ENV.gcc_4_2
    ENV['LD'] = '/usr/bin/ld'

    coredir = Dir.pwd
    Gpp.new.brew { system "ditto", Dir.pwd, coredir }
    Gobjc.new.brew { system "ditto", Dir.pwd, coredir }

    # GCC 4.6.x explictly looks for CLooG 0.16, and we use 0.17
    # Hack from http://joelinoff.com/blog/?p=108
    inreplace 'gcc/graphite-clast-to-gimple.c', ' LANGUAGE_C', ' CLOOG_LANGUAGE_C'

    build_dir='build'
    mkdir build_dir
    Dir.chdir build_dir do
      system "../configure", "--prefix=#{prefix}",
                  "--enable-shared", "--enable-lto", "--enable-plugin",
                  "--enable-languages=c,c++,objc",
                  "--enable-checking=release",
                  "--with-gmp=#{Formula.factory('gmp').prefix}",
                  "--with-mpfr=#{Formula.factory('mpfr').prefix}",
                  "--with-mpc=#{Formula.factory('libmpc').prefix}",
                  "--with-ppl=#{Formula.factory('ppl').prefix}",
                  "--with-cloog=#{Formula.factory('cloog').prefix}",
                  "--with-libelf=#{Formula.factory('libelf').prefix}",
                  "--enable-cloog-backend=isl",
                  "--disable-cloog-version-check",
                  "--disable-debug", "--disable-dependency-tracking"
      system "make"
      system "make install"
    end
  end
end

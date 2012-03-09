require 'formula'

class Gpp <Formula
  url       'http://ftpmirror.gnu.org/gcc/gcc-4.6.2/gcc-g++-4.6.2.tar.bz2'
  homepage  'http://gcc.gnu.org/'
  sha1      'f0bc2b4e1c23c5dc1462599efd5df4b9807b23af'
end

class Gobjc <Formula
  url       'http://ftpmirror.gnu.org/gcc/gcc-4.6.2/gcc-objc-4.6.2.tar.bz2'
  homepage  'http://gcc.gnu.org/'
  sha1      '32e5fbc31f1e8dd5e7c7e7ed9172afaf6136ea4e'
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

  def install
    ENV.gcc_4_2
    ENV['LD'] = '/usr/bin/ld'

    coredir = Dir.pwd
    Gpp.new.brew { system "ditto", Dir.pwd, coredir }
    Gobjc.new.brew { system "ditto", Dir.pwd, coredir }

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
                  "--disable-debug", "--disable-dependency-tracking"
      system "make"
      system "make install"
    end
  end
end

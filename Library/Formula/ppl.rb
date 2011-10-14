require 'formula'

class Ppl < Formula
  url 'http://bugseng.com/products/ppl/download/ftp/releases/0.11.2/ppl-0.11.2.tar.bz2'
  homepage 'http://bugseng.com/products/ppl/'
  md5 'c24429e6c3bc97d45976a63f40f489a1'

  depends_on 'gmp'
  depends_on 'mpfr'

  # Note: if ppl fails to build with a "was defined here" error, you may want
  # to move a previous installation of PPL out of the way during the build
  #   move Cellar/ppl/0.10.2 ~/ppl
  #   brew install ppl
  #   move ~/ppl Cellar/ppl/0.10.2
  def install
    ENV.append "CFLAGS", "-D__GMP_BITS_PER_MP_LIMB=GMP_NUMB_BITS"
    ENV.append "CXXFLAGS", "-D__GMP_BITS_PER_MP_LIMB=GMP_NUMB_BITS"
    # Heavy GCC optimizations make each process to eat up to 700MiB of RAM.
    # i5/i7 machines with less than 8GiB of RAM start swapping, which in turn
    # dramatically slow down the compilation while leaving the machine hardly
    # usable. Choose the safe way: do not parallelize the build as there is
    # no simple way to choose a optimum job count based on processor_count/RAM
    # ratio
    ENV.deparallelize
    args = ["--prefix=#{prefix}",
            "--with-gmp=#{Formula.factory('gmp').prefix}",
            "--with-mpfr=#{Formula.factory('mpfr').prefix}",
            "--enable-optimization=sspeed"]
    args << "--enable-arch=x86-64" if Hardware.is_64_bit? and MACOS_VERSION >= 10.6

    system './configure', *args
    system "make"
    system "make install"
  end
end

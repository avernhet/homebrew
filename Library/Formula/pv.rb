require 'formula'

class Pv < Formula
  url 'http://www.ivarch.com/programs/sources/pv-1.3.4.tar.bz2'
  homepage 'http://www.ivarch.com/programs/pv.shtml'
  md5 '8041eac8a2942ef11ce6c7559cc4fb0a'

  fails_with :llvm do
    build 2334
  end

  def install
    # clang cannot be used to repackage object files into a single object file
    # use regular LD instead
    ENV['LD'] = 'ld'
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--disable-nls"
    system "make install"
  end
end

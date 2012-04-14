require 'formula'

class Libserf < Formula
  url 'http://serf.googlecode.com/files/serf-1.0.1.tar.bz2'
  homepage 'http://code.google.com/p/serf/'
  sha1 '927cac9bbffeb7a60f49ba5ccd1c693d10c94142'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end


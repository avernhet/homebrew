require 'formula'

class Libserf < Formula
  url 'http://serf.googlecode.com/files/serf-1.0.0.tar.bz2'
  homepage 'http://code.google.com/p/serf/'
  sha1 'f959f1b1a475d5a1c8957db0fd6ef915b3a7575d'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end


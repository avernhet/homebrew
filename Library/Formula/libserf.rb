require 'formula'

class Libserf < Formula
  url 'http://serf.googlecode.com/files/serf-0.7.2.tar.bz2'
  homepage 'http://code.google.com/p/serf/'
  sha1 '132fbb13d50c4f849231eee79dcada8cde3ecad2'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end


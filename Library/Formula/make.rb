require 'formula'

class Make < Formula
  homepage 'http://www.gnu.org/software/make/'
  url 'http://ftpmirror.gnu.org/gnu/make/make-3.82.tar.bz2'
  sha1 'b8a8a99e4cb636a213aad3816dda827a92b9bbed'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end
end

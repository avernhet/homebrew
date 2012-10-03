require 'formula'

class Libelf < Formula
  homepage 'http://www.mr511.de/software/'
  url 'http://www.mr511.de/software/libelf-0.8.13.tar.gz'
  sha1 'c1d6ac5f182d19dd685c4dfd74eedbfe3992425d'

  def install
    args = ["--disable-debug",
            "--disable-dependency-tracking",
            "--prefix=#{prefix}"]
    args << "--disable-nls" unless Formula.factory('gettext').installed?

    system "./configure", *args
    # Use separate steps; there is some kind of (transient)
    # race in the Makefile.
    system "make"
    system "make install"
  end
end

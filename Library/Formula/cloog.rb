require 'formula'

class Cloog <Formula
  url 'http://www.bastoul.net/cloog/pages/download/cloog-0.16.3.tar.gz'
  homepage 'http://www.bastoul.net/cloog/'
  sha1 'f6765fa231f38c2f747e2b05e4eaaa470fd5851a'

  depends_on 'gmp'
  depends_on 'gnu-libtool' => :build

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--with-gmp=#{Formula.factory('gmp').prefix}"
    # I am SO tired of the autotools mess...
    # Replace the buggy generated libtool with the Homebrew one
    File.unlink "libtool"
    File.symlink "#{HOMEBREW_PREFIX}/bin/libtool", "libtool"
    system "make"
    system "make install"
  end
end

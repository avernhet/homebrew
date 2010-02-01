require 'formula'

class Uncrustify <Formula
  url 'http://downloads.sourceforge.net/project/uncrustify/uncrustify/uncrustify-0.55/uncrustify-0.55.tar.gz?use_mirror=kent'
  homepage 'http://uncrustify.sourceforge.net/'
  md5 'ecf61c26d5206bbc81367468827b55ac'
  version '0.55'

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make install"
  end
end

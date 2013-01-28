require 'formula'

class Libusbx < Formula
  homepage 'http://libusbx.org'
  url 'downloads.sourceforge.net/project/libusbx/releases/1.0.12/source/libusbx-1.0.12.tar.bz2'
  sha1 '53621af3f667844207de862fcc39f9b5a4e99c42'

  def options
    [["--universal", "Build a universal binary."]]
  end

  if ARGV.build_head? and MacOS.xcode_version >= "4.3"
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def install
    ENV.universal_binary if ARGV.build_universal?
    system "./autogen.sh" if ARGV.build_head?
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make install"
  end
end

require 'formula'

class Libusb0 <Formula
  url 'http://downloads.sourceforge.net/project/libusb/libusb-0.1%20%28LEGACY%29/0.1.12/libusb-0.1.12.tar.gz'
  homepage 'http://libusb.sourceforge.net'
  md5 'caf182cbc7565dac0fd72155919672e6'

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"
    # make install fails on the first call, but succeed on second one
    # as we don't really dare to fix an outdated library, the following kludge should be enough
    system "make install; make install"
  end
end

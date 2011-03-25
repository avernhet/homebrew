require 'formula'

class Urjtag < Formula
  url 'http://downloads.sourceforge.net/project/urjtag/urjtag/0.10/urjtag-0.10.tar.gz'
  homepage 'http://urjtag.org/'
  md5 'f7d1236a1e3ed2cf37cff1987f046195'

  depends_on 'libftdi' if ARGV.include? "--with-ftdi"
  depends_on 'libusb' if ARGV.include? "--with-ftdi"

  def options
    [["--with-ftdi", "Include FTDI support"]]
  end

  def install
    args = ["--disable-debug", 
            "--disable-dependency-tracking",
            "--prefix=#{prefix}"]
    if ARGV.include? "--with-ftdi"
      args << "--enable-cable=ft2232"
      args << "--enable-lowlevel=ftdi"
      args << "--with-libftdi"
      ENV['CPPFLAGS'] = "-I#{Formula.factory('libusb').prefix}/include/libusb-1.0"
    end
    system "./configure", *args
    system "make install"
  end
end

require 'formula'

class NoExpatFramework < Requirement
  def message; <<-EOS.undent
    Detected /Library/Frameworks/expat.framework

    This will be picked up by CMake's build system and likely cause the
    build to fail, trying to link to a 32-bit version of expat.

    You may need to move this file out of the way to compile CMake.
    EOS
  end
  def satisfied?
    not File.exist? "/Library/Frameworks/expat.framework"
  end
end


class Cmake < Formula
  homepage 'http://www.cmake.org/'
  url 'http://www.cmake.org/files/v2.8/cmake-2.8.9.tar.gz'
  sha1 'b96663c0757a5edfbddc410aabf7126a92131e2b'

  bottle do
    version 3
    sha1 '64e1a488bc669f7676c99874b8496ac147d1bc70' => :mountainlion
    sha1 'bdfb5fcd6743d65f6cfe00b314f9d3f1049e902b' => :lion
    sha1 '3a77fc17a7b1d3cceabddcca5c126c6b911c2f90' => :snowleopard
  end

  depends_on NoExpatFramework.new

  def options
    [["--enable-ninja", "Enable Ninja build system support"]]
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --system-libs
      --no-system-libarchive
      --datadir=/share/cmake
      --docdir=/share/doc/cmake
      --mandir=/share/man
    ]

    if ARGV.include? "--enable-ninja"
      args << "--"
      args << "-DCMAKE_ENABLE_NINJA=1"
    end

    system "./bootstrap", *args
    system "make"
    system "make install"
  end

  def test
    system "#{bin}/cmake", "-E", "echo", "testing"
  end
end

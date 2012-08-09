require 'formula'

class Ninja < Formula
  homepage 'https://github.com/martine/ninja'
  head 'git://github.com/martine/ninja.git'

  # depends_on 'cmake' => :build

  def install
    system "./bootstrap.py"
    system "mkdir -p #{prefix}/bin"
    system "cp ninja #{prefix}/bin/"
  end

end

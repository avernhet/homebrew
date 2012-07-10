require 'formula'

class Qemu < Formula
  homepage 'http://www.qemu.org/'
  url 'http://wiki.qemu.org/download/qemu-1.1.0-1.tar.bz2'
  sha256 '1e566f8cbc33e5fb7d5f364c0fd1cdde9e921e647223b5d7ae7e5f95544b258d'

  depends_on 'jpeg'
  depends_on 'gnutls'
  depends_on 'glib'

  fails_with :clang do
    build 318
    cause 'Compile error: global register variables are not supported'
  end

  def patches
    DATA
  end

  def install
    # Disable the sdl backend. Let it use CoreAudio instead.
    args = %W[
      --prefix=#{prefix}
      --cc=#{ENV.cc}
      --host-cc=#{ENV.cc}
      --enable-cocoa
      --disable-bsd-user
      --disable-guest-agent
      --disable-sdl
    ]
    system "./configure", *args
    system "make install"
  end
end

__END__
diff -u a/fpu/softfloat.h b/fpu/softfloat.h
--- a/fpu/softfloat.h	2011-12-01 21:07:34.000000000 +0100
+++ b/fpu/softfloat.h	2012-02-15 00:33:28.000000000 +0100
@@ -56,10 +56,14 @@
 typedef uint8_t flag;
 typedef uint8_t uint8;
 typedef int8_t int8;
-#ifndef _AIX
+#if ! defined (_AIX) && ! defined (__APPLE__)
 typedef int uint16;
 typedef int int16;
 #endif
+#if defined (__APPLE__)
+typedef uint16_t uint16;
+typedef int16_t int16;
+#endif
 typedef unsigned int uint32;
 typedef signed int int32;
 typedef uint64_t uint64;

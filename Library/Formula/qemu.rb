require 'formula'

class Qemu < Formula
  url 'http://wiki.qemu.org/download/qemu-1.0.tar.gz'
  homepage 'http://www.qemu.org/'
  md5 'a64b36067a191451323b0d34ebb44954'

  depends_on 'jpeg'
  depends_on 'gnutls'

  fails_with_llvm "Segmentation faults occur at run-time with LLVM using qemu-system-arm."

  def patches
    DATA
  end

  def install
    ENV.gcc_4_2
    system "./configure", "--prefix=#{prefix}",
                          "--disable-user",
                          "--enable-cocoa",
                          "--disable-guest-agent"
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

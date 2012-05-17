require 'formula'

class Qemu < Formula
  homepage 'http://www.qemu.org/'
  url 'http://wiki.qemu.org/download/qemu-1.0.1.tar.gz'
  sha1 '4d08b5a83538fcd7b222bec6f1c584da8d12497a'

  depends_on 'jpeg'
  depends_on 'gnutls'
  depends_on 'glib'

  fails_with :clang do
    build 318
  end

  # Borrow these patches from MacPorts
  def patches
    { :p0 => [
      "https://trac.macports.org/export/92470/trunk/dports/emulators/qemu/files/patch-configure.diff",
      "https://trac.macports.org/export/92470/trunk/dports/emulators/qemu/files/patch-cocoa-uint16-redefined.diff"
    ]}
  end

  def patches
    DATA
  end

  def install
    ENV.gcc_4_2
    system "./configure", "--prefix=#{prefix}",
                          "--cc=#{ENV.cc}",
                          "--host-cc=#{ENV.cc}",
                          "--disable-darwin-user",
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

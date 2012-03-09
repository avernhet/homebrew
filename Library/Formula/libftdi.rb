require 'formula'

class Libftdi < Formula
  url "http://www.intra2net.com/en/developer/libftdi/download/libftdi-0.19.tar.gz"
  homepage 'http://www.intra2net.com/en/developer/libftdi'
  md5 'e6e25f33b4327b1b7aa1156947da45f3'

  depends_on 'pkg-config' => :build
  depends_on 'boost'
  depends_on 'libusb-compat'

  def patches
    DATA
  end

  def install
    mkdir 'libftdi-build' do
      system "../configure", "--prefix=#{prefix}"
      system "make"
      system "make install"
    end
  end
end

__END__
diff -u CMakeLists.txt  ~/Desktop/CMakeLists.txt 
--- a/CMakeLists.txt	2010-06-25 17:04:04.000000000 +0200
+++ b/CMakeLists.txt	2011-06-22 18:40:48.000000000 +0200
@@ -38,15 +38,6 @@
 set(CPACK_COMPONENT_STATICLIBS_GROUP "Development")
 set(CPACK_COMPONENT_HEADERS_GROUP    "Development")
 
-# Create suffix to eventually install in lib64
-IF(CMAKE_SIZEOF_VOID_P EQUAL 4)
-    SET(LIB_SUFFIX "")
-    SET(PACK_ARCH "")
-  ELSE(CMAKE_SIZEOF_VOID_P EQUAL 8)
-    SET(LIB_SUFFIX 64)
-    SET(PACK_ARCH .x86_64)
-endif(CMAKE_SIZEOF_VOID_P EQUAL 4)
-
 # Package information
 set(CPACK_PACKAGE_VERSION              ${VERSION_STRING})
 set(CPACK_PACKAGE_CONTACT              "Marek Vavrusa <marek@vavrusa.com>")
@@ -85,8 +85,6 @@
 
 add_subdirectory(src)
 add_subdirectory(ftdipp)
-add_subdirectory(bindings)
-add_subdirectory(examples)
 add_subdirectory(packages)
 
 
--- a/src/ftdi.c	2010-06-25 17:36:53.000000000 +0200
+++ b/src/ftdi.c	2011-06-22 18:42:41.000000000 +0200
@@ -50,6 +50,9 @@
    } while(0);
 
 
+#define FTDI_BAUDRATE_REF_CLOCK 3000000 /* 3 MHz */
+#define FTDI_BAUDRATE_TOLERANCE       3 /* acceptable clock drift, in % */
+
 /**
     Internal function to close usb device pointer.
     Sets ftdi->usb_dev to NULL.
@@ -973,14 +976,28 @@
     int divisor, best_divisor, best_baud, best_baud_diff;
     unsigned long encoded_divisor;
     int i;
-
+    unsigned int ref_clock = FTDI_BAUDRATE_REF_CLOCK;
+    int hispeed = 0;
+    
     if (baudrate <= 0)
     {
         // Return error
         return -1;
     }
 
-    divisor = 24000000 / baudrate;
+    if ( (ftdi->type == TYPE_4232H) || (ftdi->type == TYPE_2232H) )
+    {
+        // these chips can support a 12MHz clock in addition to the original
+        // 3MHz clock. This allows higher baudrate (up to 12Mbps) and more
+        // precise baudrates for baudrate > 3Mbps/2
+        if ( baudrate > (FTDI_BAUDRATE_REF_CLOCK>>1) )
+        {
+            ref_clock *= 4; // 12 MHz
+            hispeed = 1;
+        }
+    }
+    
+    divisor = (ref_clock<<3) / baudrate;
 
     if (ftdi->type == TYPE_AM)
     {
@@ -998,45 +1015,49 @@
         int baud_estimate;
         int baud_diff;
 
-        // Round up to supported divisor value
-        if (try_divisor <= 8)
-        {
-            // Round up to minimum supported divisor
-            try_divisor = 8;
-        }
-        else if (ftdi->type != TYPE_AM && try_divisor < 12)
+        if ( ! hispeed )
         {
-            // BM doesn't support divisors 9 through 11 inclusive
-            try_divisor = 12;
-        }
-        else if (divisor < 16)
-        {
-            // AM doesn't support divisors 9 through 15 inclusive
-            try_divisor = 16;
-        }
-        else
-        {
-            if (ftdi->type == TYPE_AM)
+            // Round up to supported divisor value
+            if (try_divisor <= 8)
             {
-                // Round up to supported fraction (AM only)
-                try_divisor += am_adjust_up[try_divisor & 7];
-                if (try_divisor > 0x1FFF8)
-                {
-                    // Round down to maximum supported divisor value (for AM)
-                    try_divisor = 0x1FFF8;
-                }
+                // Round up to minimum supported divisor
+                try_divisor = 8;
+            }
+            else if (ftdi->type != TYPE_AM && try_divisor < 12)
+            {
+                // BM doesn't support divisors 9 through 11 inclusive
+                try_divisor = 12;
+            }
+            else if ( divisor < 16 )
+            {
+                // AM doesn't support divisors 9 through 15 inclusive
+                try_divisor = 16;
             }
             else
             {
-                if (try_divisor > 0x1FFFF)
+                if (ftdi->type == TYPE_AM)
                 {
-                    // Round down to maximum supported divisor value (for BM)
-                    try_divisor = 0x1FFFF;
+                    // Round up to supported fraction (AM only)
+                    try_divisor += am_adjust_up[try_divisor & 7];
+                    if (try_divisor > 0x1FFF8)
+                    {
+                        // Round down to maximum supported divisor value (for AM)
+                        try_divisor = 0x1FFF8;
+                    }
+                }
+                else
+                {
+                    if (try_divisor > 0x1FFFF)
+                    {
+                        // Round down to maximum supported divisor value (for BM)
+                        try_divisor = 0x1FFFF;
+                    }
                 }
             }
         }
+
         // Get estimated baud rate (to nearest integer)
-        baud_estimate = (24000000 + (try_divisor / 2)) / try_divisor;
+        baud_estimate = ((ref_clock<<3) + (try_divisor / 2)) / try_divisor;
         // Get absolute difference from requested baud rate
         if (baud_estimate < baudrate)
         {
@@ -1079,7 +1100,13 @@
         *index |= ftdi->index;
     }
     else
+    {
         *index = (unsigned short)(encoded_divisor >> 16);
+    }
+    if ( hispeed )
+    {
+        *index |= 1<<9; // use hispeed mode
+    }
 
     // Return the nearest baud rate
     return best_baud;

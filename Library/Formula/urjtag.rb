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

  def patches
    DATA
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

__END__
diff -ur a/src/tap/cable/ft2232.c b/src/tap/cable/ft2232.c
--- a/src/tap/cable/ft2232.c	2009-04-17 22:24:10.000000000 +0200
+++ b/src/tap/cable/ft2232.c	2011-03-25 00:12:09.000000000 +0100
@@ -1615,6 +1615,7 @@
 usbconn_cable_t usbconn_cable_armusbocd_ftdi;
 usbconn_cable_t usbconn_cable_gnice_ftdi;
 usbconn_cable_t usbconn_cable_jtagkey_ftdi;
+usbconn_cable_t usbconn_cable_ft4232_ftdi;
 usbconn_cable_t usbconn_cable_oocdlinks_ftdi;
 usbconn_cable_t usbconn_cable_turtelizer2_ftdi;
 usbconn_cable_t usbconn_cable_usbtojtagif_ftdi;
@@ -1637,6 +1638,9 @@
   conn = &usbconn_cable_jtagkey_ftdi;
   if (strcasecmp( conn->name, cablename ) == 0)
     goto found;
+  conn = &usbconn_cable_ft4232_ftdi;
+  if (strcasecmp( conn->name, cablename ) == 0)
+    goto found;
   conn = &usbconn_cable_oocdlinks_ftdi;
   if (strcasecmp( conn->name, cablename ) == 0)
     goto found;
@@ -1817,6 +1821,38 @@
   0xCFF8              /* PID */
 };
 
+cable_driver_t ft2232_ft4232_cable_driver = {
+  "Ft4232",
+  N_("Ft4232 CAM extender Cable"),
+  ft2232_connect,
+  generic_disconnect,
+  ft2232_cable_free,
+  ft2232_generic_init,
+  ft2232_generic_done,
+  ft2232_set_frequency,
+  ft2232_clock,
+  ft2232_get_tdo,
+  ft2232_transfer,
+  ft2232_set_signal,
+  generic_get_signal,
+  ft2232_flush,
+  ft2232_usbcable_help
+};
+usbconn_cable_t usbconn_cable_ft4232_ftdi = {
+  "Ft4232",          /* cable name */
+  NULL,               /* string pattern, not used */
+  "ftdi-mpsse",       /* default usbconn driver */
+  0x0403,             /* VID */
+  0x6011              /* PID */
+};
+usbconn_cable_t usbconn_cable_ft4232_ftd2xx = {
+  "Ft4232",          /* cable name */
+  NULL,               /* string pattern, not used */
+  "ftd2xx-mpsse",     /* default usbconn driver */
+  0x0403,             /* VID */
+  0x6011              /* PID */
+};
+
 cable_driver_t ft2232_oocdlinks_cable_driver = {
   "OOCDLink-s",
   N_("OOCDLink-s (FT2232) Cable (EXPERIMENTAL)"),
diff -ur a/src/tap/cable/generic_usbconn.c b/src/tap/cable/generic_usbconn.c
--- a/src/tap/cable/generic_usbconn.c	2009-04-17 22:24:10.000000000 +0200
+++ b/src/tap/cable/generic_usbconn.c	2011-03-25 00:07:45.000000000 +0100
@@ -64,6 +64,7 @@
 extern usbconn_cable_t usbconn_cable_armusbocdtiny_ftdi;
 extern usbconn_cable_t usbconn_cable_gnice_ftdi;
 extern usbconn_cable_t usbconn_cable_jtagkey_ftdi;
+extern usbconn_cable_t usbconn_cable_ft4232_ftdi;
 extern usbconn_cable_t usbconn_cable_oocdlinks_ftdi;
 extern usbconn_cable_t usbconn_cable_turtelizer2_ftdi;
 extern usbconn_cable_t usbconn_cable_usbtojtagif_ftdi;
@@ -116,6 +117,7 @@
 	&usbconn_cable_armusbocdtiny_ftdi,
 	&usbconn_cable_gnice_ftdi,
 	&usbconn_cable_jtagkey_ftdi,
+	&usbconn_cable_ft4232_ftdi,
 	&usbconn_cable_oocdlinks_ftdi,
 	&usbconn_cable_turtelizer2_ftdi,
 	&usbconn_cable_usbtojtagif_ftdi,
diff -ur a/src/tap/cable.c b/src/tap/cable.c
--- a/src/tap/cable.c	2009-04-17 22:24:10.000000000 +0200
+++ b/src/tap/cable.c	2011-03-25 00:07:07.000000000 +0100
@@ -44,6 +44,7 @@
 extern cable_driver_t usbblaster_cable_driver;
 extern cable_driver_t ft2232_cable_driver;
 extern cable_driver_t ft2232_jtagkey_cable_driver;
+extern cable_driver_t ft2232_ft4232_cable_driver;
 extern cable_driver_t ft2232_armusbocd_cable_driver;
 extern cable_driver_t ft2232_gnice_cable_driver;
 extern cable_driver_t ft2232_oocdlinks_cable_driver;
@@ -85,6 +86,7 @@
 #ifdef ENABLE_CABLE_FT2232
 	&ft2232_cable_driver,
 	&ft2232_jtagkey_cable_driver,
+	&ft2232_ft4232_cable_driver,
 	&ft2232_armusbocd_cable_driver,
 	&ft2232_gnice_cable_driver,
 	&ft2232_oocdlinks_cable_driver,

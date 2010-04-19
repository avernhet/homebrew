require 'formula'

# On 10.5 we need newer versions of apr, neon etc.
# On 10.6 we only need a newer version of neon
class SubversionDeps <Formula
  url 'http://subversion.tigris.org/downloads/subversion-deps-1.6.11.tar.bz2'
  md5 'da1bcdd39c34d91e434407f72b844f2f'

  # Note because this formula is installed into the subversion prefix
  # it is not in fact keg only
  def keg_only?
    :provided_by_osx
  end
end

class Subversion <Formula
  url 'http://subversion.tigris.org/downloads/subversion-1.6.11.tar.bz2'
  md5 '75419159b50661092c4137449940b5cc'
  homepage 'http://subversion.apache.org/'
  
  aka :svn

  # Only need this on Snow Leopard; for Leopard the deps package 
  # builds it.
  depends_on 'neon' if MACOS_VERSION >= 10.6

  def setup_leopard
    # Slot dependencies into place
    d=Pathname.getwd
    SubversionDeps.new.brew do
      d.install Dir['*']
    end
  end

  def patches
    DATA
  end

  def install
    setup_leopard if MACOS_VERSION < 10.6

    # Use existing system zlib
    # Use dep-provided other libraries
    # Don't mess with Apache modules (since we're not sudo)
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--with-ssl",
                          "--with-zlib=/usr/lib",
                          # use our neon, not OS X's 
                          "--disable-neon-version-check",
                          "--disable-mod-activation",
                          "--without-apache-libexecdir",
                          "--without-berkeley-db"
    system "make"
    system "make install"
  end
end

__END__
--- a/configure	2010-01-20 21:41:31.000000000 +0100
+++ b/configure	2010-03-11 23:33:56.000000000 +0100
@@ -22197,7 +22197,7 @@
   return 0;
 }
 _ACEOF
-for ac_lib in '' intl; do
+for ac_lib in ''; do
   if test -z "$ac_lib"; then
     ac_res="none required"
   else
@@ -22262,7 +22262,7 @@
   return 0;
 }
 _ACEOF
-for ac_lib in '' intl; do
+for ac_lib in ''; do
   if test -z "$ac_lib"; then
     ac_res="none required"
   else

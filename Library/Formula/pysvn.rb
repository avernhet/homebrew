require 'formula'

class Pysvn < Formula
  url 'http://pysvn.barrys-emacs.org/source_kits/pysvn-1.7.5.tar.gz'
  homepage 'http://pysvn.tigris.org/'
  md5 '3334718248ec667b17d333aac73d5680'

  depends_on 'python'
  depends_on 'subversion'

  def patches
    DATA
  end

  def install
    python = "#{Formula.factory('python').prefix}/bin/python"
    system "#{python} setup.py egg_info"
    Dir.chdir "Source"
    system "#{python} setup.py configure " \
      "--svn-root-dir=#{Formula.factory('subversion').prefix}"
    Dir.chdir ".."
    pydir = "#{Formula.factory('python').prefix}"
    ENV.append "PYTHONPATH", "#{pydir}"
    system "#{python} setup.py install --prefix=#{pydir}"
  end
end

__END__
diff -u -r a/Source/setup_configure.py b/Source/setup_configure.py
--- a/Source/setup_configure.py	2010-12-31 14:19:01.000000000 +0100
+++ b/Source/setup_configure.py	2011-05-24 00:00:44.000000000 +0200
@@ -337,7 +337,7 @@
             # python framework will be used and not the one matching this python
             var_prefix = distutils.sysconfig.get_config_var('prefix')
             var_ldlibrary = distutils.sysconfig.get_config_var('LDLIBRARY')
-            framework_lib = os.path.join( var_prefix, os.path.basename( var_ldlibrary ) )
+            framework_lib = os.path.join( var_prefix, 'lib', os.path.basename( var_ldlibrary ) )

             if self.is_atleast_mac_os_x_version( (10,5) ) >= 0:
                 if self.verbose:

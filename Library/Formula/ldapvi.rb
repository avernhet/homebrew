require 'formula'

class Ldapvi < Formula
  url 'http://www.lichteblau.com/download/ldapvi-1.7.tar.gz'
  homepage 'http://www.lichteblau.com/ldapvi/'
  md5 '6dc2f5441ac5f1e2b5b036e3521012cc'

  depends_on 'gettext'
  depends_on 'glib'
  depends_on 'popt'
  depends_on 'readline'

  def patches
    DATA
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"
    system "make install"
  end
end
__END__
diff -ur a/common.h b/common.h
--- a/common.h	2007-05-05 12:17:26.000000000 +0200
+++ b/common.h	2011-07-04 12:47:59.000000000 +0200
@@ -273,7 +273,7 @@
 char *home_filename(char *name);
 void read_ldapvi_history(void);
 void write_ldapvi_history(void);
-char *getline(char *prompt, char *value);
+char *getline1(char *prompt, char *value);
 char *get_password();
 char *append(char *a, char *b);
 void *xalloc(size_t size);
diff -ur a/ldapvi.c b/ldapvi.c
--- a/ldapvi.c	2007-05-05 12:17:26.000000000 +0200
+++ b/ldapvi.c	2011-07-04 12:47:59.000000000 +0200
@@ -470,7 +470,7 @@
 		bo->authmethod = LDAP_AUTH_SASL;
 		puts("Switching to SASL authentication.");
 	}
-	bo->sasl_mech = getline("SASL mechanism", bo->sasl_mech);
+	bo->sasl_mech = getline1("SASL mechanism", bo->sasl_mech);
 }
 
 static int
diff -ur a/misc.c b/misc.c
--- a/ldapvi-1.7/misc.c	2007-05-05 12:17:26.000000000 +0200
+++ b/misc.c	2011-07-04 12:47:59.000000000 +0200
@@ -315,7 +315,7 @@
 }
 
 char *
-getline(char *prompt, char *value)
+getline1(char *prompt, char *value)
 {
 	tdialog d;
 	init_dialog(&d, DIALOG_DEFAULT, prompt, value);


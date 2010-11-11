require 'formula'

class GppArmEcos <Formula
  url       'http://ftpmirror.gnu.org/gcc/gcc-4.5.1/gcc-g++-4.5.1.tar.bz2'
  homepage  'http://gcc.gnu.org/'
  md5       '10e14c901fc3728eecbd5b829e011b59'
end

class NewLibArmEcos <Formula
  url       'ftp://sources.redhat.com/pub/newlib/newlib-1.18.0.tar.gz'
  homepage  'http://sourceware.org/newlib/'
  md5       '10e14c901fc3728eecbd5b829e011b59'
end

class GccArmEcos <Formula
  url       'http://ftpmirror.gnu.org/gcc/gcc-4.5.1/gcc-core-4.5.1.tar.bz2'
  homepage  'http://gcc.gnu.org/'
  sha1      'dda4efdd310c232013614f4401d2427e209348ce'
  version   '4.5.2'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'libmpc'
  depends_on 'ppl'
  depends_on 'cloog-ppl'
  depends_on 'libelf'
  depends_on 'binutils-arm-ecos'

  def patches
    DATA
  end

  def install
    
    gpp_dir = Pathname.new(Dir.pwd)
    GppArmEcos.new.brew { gpp_dir.install Dir['*'] }

    newlib_dir = Pathname.new(Dir.pwd)
    NewLibArmEcos.new.brew { newlib_dir.install Dir['libgloss', 'liberty'] }
    
    # Cannot build with LLVM (cross compiler crashes)
    ENV.gcc_4_2
    # Fix up CFLAGS for cross compilation (default switches cause build issues)
    ENV['CFLAGS_FOR_BUILD'] = "-O2"
    ENV['CFLAGS'] = "-O2"
    ENV['CFLAGS_FOR_TARGET'] = "-O2"
    ENV['CXXFLAGS_FOR_BUILD'] = "-O2"
    ENV['CXXFLAGS'] = "-O2"
    ENV['CXXFLAGS_FOR_TARGET'] = "-O2"

    build_dir='build'
    mkdir build_dir
    Dir.chdir build_dir do
      system "../configure", "--prefix=#{prefix}", "--target=arm-eabi",
                  "--enable-shared", "--with-gnu-as", "--with-gnu-ld",
                  "--with-newlib", "--enable-softfloat", "--disable-bigendian",
                  "--disable-fpu", "--disable-underscore", "--enable-multilibs",
                  "--with-float=soft", "--enable-interwork", "--enable-lto",
                  "--enable-plugin", "--with-multilib-list=interwork", 
                  "--with-abi=aapcs", "--enable-languages=c,c++",
                  "--with-gmp=#{Formula.factory('gmp').prefix}",
                  "--with-mpfr=#{Formula.factory('mpfr').prefix}",
                  "--with-mpc=#{Formula.factory('libmpc').prefix}",
                  "--with-ppl=#{Formula.factory('ppl').prefix}",
                  "--with-cloog=#{Formula.factory('cloog-ppl').prefix}",
                  "--with-libelf=#{Formula.factory('libelf').prefix}",
                  "--with-gxx-include-dir=#{prefix}/arm-eabi/include",
                  "--disable-debug", "--disable-__cxa_atexit",
                  "--with-pkgversion=Neotion-SDK-Monica",
                  "--with-bugurl=http://www.neotion.com"
      system "make"
      system "make install"
    end

    ln_s "#{Formula.factory('binutils-arm-ecos').prefix}/arm-eabi/bin",
                   "#{prefix}/arm-eabi/bin"
  end
end

__END__
--- a/gcc/config/arm/t-arm-elf	2008-06-12 19:29:47.000000000 +0200
+++ b/gcc/config/arm/t-arm-elf	2010-01-14 00:44:48.000000000 +0100
@@ -65,8 +65,8 @@
 # MULTILIB_DIRNAMES   += fpu soft
 # MULTILIB_EXCEPTIONS += *mthumb/*mhard-float*
 # 
-# MULTILIB_OPTIONS    += mno-thumb-interwork/mthumb-interwork
-# MULTILIB_DIRNAMES   += normal interwork
+MULTILIB_OPTIONS    += mno-thumb-interwork/mthumb-interwork
+MULTILIB_DIRNAMES   += normal interwork
 # 
 # MULTILIB_OPTIONS    += fno-leading-underscore/fleading-underscore
 # MULTILIB_DIRNAMES   += elf under
--- a/gcc/config/386/i386.c	2010-07-23 18:20:40.000000000 +0200
+++ b/gcc/config/i386/i386.c	2010-07-23 18:22:33.436581657 +0200
@@ -4991,7 +4991,8 @@
    case, we return the original mode and warn ABI change if CUM isn't
    NULL.  */
 
-static enum machine_mode
+enum machine_mode type_natural_mode (const_tree, CUMULATIVE_ARGS *);
+enum machine_mode
 type_natural_mode (const_tree type, CUMULATIVE_ARGS *cum)
 {
   enum machine_mode mode = TYPE_MODE (type);
@@ -5122,7 +5123,9 @@
    See the x86-64 PS ABI for details.
 */
 
-static int
+int classify_argument (enum machine_mode, const_tree,
+                       enum x86_64_reg_class [MAX_CLASSES], int);
+int
 classify_argument (enum machine_mode mode, const_tree type,
 		   enum x86_64_reg_class classes[MAX_CLASSES], int bit_offset)
 {
@@ -5503,7 +5506,8 @@
 
 /* Examine the argument and return set number of register required in each
    class.  Return 0 iff parameter should be passed in memory.  */
-static int
+int examine_argument (enum machine_mode, const_tree, int, int *, int *);
+int
 examine_argument (enum machine_mode mode, const_tree type, int in_return,
 		  int *int_nregs, int *sse_nregs)
 {
@@ -6184,7 +6188,8 @@
 
 /* Return true when TYPE should be 128bit aligned for 32bit argument passing
    ABI.  */
-static bool
+bool contains_aligned_value_p (const_tree);
+bool
 contains_aligned_value_p (const_tree type)
 {
   enum machine_mode mode = TYPE_MODE (type);
--- a/gcc/testsuite/lib/plugin-support.exp	(revision 158252)
+++ b/gcc/testsuite/lib/plugin-support.exp	(working copy)
@@ -88,6 +88,10 @@
 
     set optstr "$includes $extra_flags -DIN_GCC -fPIC -shared"
 
+    if { [ ishost *-*-darwin* ] } {
+        set optstr [concat $optstr "-undefined dynamic_lookup"]
+    }
+
     # Temporarily switch to the environment for the plugin compiler.
     restore_ld_library_path_env_vars
     set status [remote_exec build "$PLUGINCC $PLUGINCFLAGS $plugin_src $optstr -o $plugin_lib"]
--- a/gcc/configure.ac	(revision 158252)
+++ b/gcc/configure.ac	(working copy)
@@ -4440,15 +4440,20 @@
 pluginlibs=
 if test x"$enable_plugin" = x"yes"; then
 
+  if test -z "$gcc_cv_objdump"; then
+    export_sym_check="$gcc_cv_nm -g"
+  else
+    export_sym_check="$gcc_cv_objdump -T"
+  fi  
   AC_MSG_CHECKING([for exported symbols])
   echo "int main() {return 0;} int foobar() {return 0;}" > conftest.c
   ${CC} ${CFLAGS} ${LDFLAGS} conftest.c -o conftest > /dev/null 2>&1
-  if $gcc_cv_objdump -T conftest | grep foobar > /dev/null; then
+  if $export_sym_check conftest | grep foobar > /dev/null; then
     : # No need to use a flag
   else
     AC_MSG_CHECKING([for -rdynamic])
     ${CC} ${CFLAGS} ${LDFLAGS} -rdynamic conftest.c -o conftest > /dev/null 2>&1
-    if $gcc_cv_objdump -T conftest | grep foobar > /dev/null; then
+    if $export_sym_check conftest | grep foobar > /dev/null; then
       plugin_rdynamic=yes
       pluginlibs="-rdynamic"
     else
@@ -4468,7 +4473,14 @@
 
   # Check that we can build shared objects with -fPIC -shared
   saved_LDFLAGS="$LDFLAGS"
-  LDFLAGS="$LDFLAGS -fPIC -shared"
+  case "${host}" in
+    *-*-darwin*)
+      LDFLAGS="$LDFLAGS -fPIC -shared -undefined dynamic_lookup"
+    ;;
+    *)
+      LDFLAGS="$LDFLAGS -fPIC -shared"
+    ;;
+  esac
   AC_MSG_CHECKING([for -fPIC -shared])
   AC_TRY_LINK(
     [extern int X;],[return X == 0;],

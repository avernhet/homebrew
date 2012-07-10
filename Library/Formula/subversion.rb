require 'formula'

def build_java?;   ARGV.include? "--java";   end
def build_perl?;   ARGV.include? "--perl";   end
def build_python?; ARGV.include? "--python"; end
def build_ruby?;   ARGV.include? "--ruby";   end
def with_unicode_path?; ARGV.include? "--unicode-path"; end
def build_universal?; ARGV.build_universal?; end

class UniversalNeon < Requirement
  def message; <<-EOS.undent
      A universal build was requested, but neon was already built for a single arch.
      You will need to `brew rm neon` first.
    EOS
  end

  def fatal?
    true
  end

  def satisfied?
    f = Formula.factory('neon')
    !f.installed? || archs_for_command(f.lib+'libneon.dylib').universal?
  end
end

class UniversalSqlite < Requirement
  def message; <<-EOS.undent
      A universal build was requested, but sqlite was already built for a single arch.
      You will need to `brew rm sqlite` first.
    EOS
  end

  def fatal?
    true
  end

  def satisfied?
    f = Formula.factory('sqlite')
    !f.installed? || archs_for_command(f.lib+'libsqlite3.dylib').universal?
  end
end

class UniversalSerf < Requirement
  def message; <<-EOS.undent
      A universal build was requested, but serf was already built for a single arch.
      You will need to `brew rm serf` first.
    EOS
  end

  def fatal?
    true
  end

  def satisfied?
    f = Formula.factory('serf')
    !f.installed? || archs_for_command(f.lib+'libserf-1.0.0.0.dylib').universal?
  end
end

class Subversion < Formula
  homepage 'http://subversion.apache.org/'
  url 'http://www.apache.org/dyn/closer.cgi?path=subversion/subversion-1.7.5.tar.bz2'
  sha1 '05c079762690d5ac1ccd2549742e7ef70fa45cf1'

  depends_on 'pkg-config' => :build
  depends_on 'sqlite'  # could be optional, but many issues with dynamic
                       # linking arised with the system's SQLite package
  depends_on 'libserf' # could be optional, but this package has already far
                       # too many options. libserf is the recommended library
                       # with SVN 1.7+ (vs. libneon)

  if ARGV.build_universal?
    depends_on UniversalNeon.new
    depends_on UniversalSqlite.new
    depends_on UniversalSerf.new
  end

  # Building Ruby bindings requires libtool
  depends_on 'libtool' if build_ruby? and MacOS.xcode_version >= "4.3"

  def options
    [
      ['--java', 'Build Java bindings.'],
      ['--perl', 'Build Perl bindings.'],
      ['--python', 'Build Python bindings.'],
      ['--ruby', 'Build Ruby bindings.'],
      ['--universal', 'Build as a Universal Intel binary.'],
      ['--unicode-path', 'Include support for OS X UTF-8-MAC filename'],
    ]
  end

  def patches
    # Patch for Subversion handling of OS X UTF-8-MAC filename.
    if with_unicode_path?
      { :p0 =>
      "https://raw.github.com/gist/1900750/4888cafcf58f7355e2656fe192a77e2b6726e338/patch-path.c.diff"
      }
    end
  end

  # When building Perl, Python or Ruby bindings, need to use a compiler that
  # recognizes GCC-style switches, since that's what the system languages
  # were compiled against.
  fails_with :clang do
    build 318
    cause "core.c:1: error: bad value (native) for -march= switch"
  end if build_perl? or build_python? or build_ruby?

  def install
    if build_java?
      unless ARGV.build_universal?
        opoo "A non-Universal Java build was requested."
        puts "To use Java bindings with various Java IDEs, you might need a universal build:"
        puts "  brew install subversion --universal --java"
      end

      unless (ENV["JAVA_HOME"] or "").empty?
        opoo "JAVA_HOME is set. Try unsetting it if JNI headers cannot be found."
      end
    end

    # Use existing system zlib
    # Use dep-provided other libraries
    # Don't mess with Apache modules (since we're not sudo)
    args = ["--disable-debug",
            "--prefix=#{prefix}",
            "--with-ssl",
            "--without-neon",
            "--with-serf=#{Formula.factory('libserf').prefix}",
            "--with-sqlite=#{Formula.factory('sqlite').prefix}",
            "--with-zlib=/usr",
            "--with-sqlite=#{HOMEBREW_PREFIX}",
            "--with-serf=#{HOMEBREW_PREFIX}",
            "--disable-mod-activation",
            "--without-apache-libexecdir",
            "--without-berkeley-db"]

    args << "--enable-javahl" << "--without-jikes" if build_java?
    args << "--with-ruby-sitedir=#{lib}/ruby" if build_ruby?

    # The system Python is built with llvm-gcc, so we override this
    # variable to prevent failures due to incompatible CFLAGS
    ENV['ac_cv_python_compile'] = ENV.cc

    system "./configure", *args
    # dirty hack for https://github.com/mxcl/homebrew/issues/5080
    # force static linkage with SQLite
    inreplace "Makefile", /SVN_SQLITE_LIBS =.*$/, \
    "SVN_SQLITE_LIBS = #{Formula.factory('sqlite').prefix}/lib/libsqlite3.a"

    system "make"
    system "make install"

    if build_python?
      system "make swig-py"
      system "make install-swig-py"
    end

    if build_perl?
      ENV.j1 # This build isn't parallel safe
      # Remove hard-coded ppc target, add appropriate ones
      if ARGV.build_universal?
        arches = "-arch x86_64 -arch i386"
      elsif MacOS.leopard?
        arches = "-arch i386"
      else
        arches = "-arch x86_64"
      end

      perl_core = Pathname.new(`perl -MConfig -e 'print $Config{archlib}'`)+'CORE'
      unless perl_core.exist?
        onoe "perl CORE directory does not exist in '#{perl_core}'"
      end

      inreplace "Makefile" do |s|
        s.change_make_var! "SWIG_PL_INCLUDES",
          "$(SWIG_INCLUDES) #{arches} -g -pipe -fno-common -DPERL_DARWIN -fno-strict-aliasing -I/usr/local/include -I#{perl_core}"
      end
      system "make swig-pl"
      system "make install-swig-pl"
    end

    if build_java?
      ENV.j1 # This build isn't parallel safe
      system "make javahl"
      system "make install-javahl"
    end

    if build_ruby?
      ENV.j1 # This build isn't parallel safe
      system "make swig-rb"
      system "make install-swig-rb"
    end
  end

  def caveats
    s = ""

    if build_python?
      s += <<-EOS.undent
        You may need to add the Python bindings to your PYTHONPATH from:
          #{HOMEBREW_PREFIX}/lib/svn-python

      EOS
    end

    if build_ruby?
      s += <<-EOS.undent
        You may need to add the Ruby bindings to your RUBYLIB from:
          #{HOMEBREW_PREFIX}/lib/ruby

      EOS
    end

    if build_java?
      s += <<-EOS.undent
        You may need to link the Java bindings into the Java Extensions folder:
          sudo mkdir -p /Library/Java/Extensions
          sudo ln -s #{HOMEBREW_PREFIX}/lib/libsvnjavahl-1.dylib /Library/Java/Extensions/libsvnjavahl-1.dylib

      EOS
    end

    if with_unicode_path?
      s += <<-EOS.undent
        This unicode-path version implements a hack to deal with composed/decomposed
        unicode handling on Mac OS X which is different from linux and windows.
        It is an implementation of solution 1 from
        http://svn.collab.net/repos/svn/trunk/notes/unicode-composition-for-filenames
        which _WILL_ break some setups. Please be sure you understand what you
        are asking for when you install this version.

      EOS
    end

    return s.empty? ? nil : s
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

require 'formula'

class Libedit <Formula
  @url='http://downloads.sourceforge.net/project/libedit/libedit/libedit-0.3/libedit-0.3.tar.gz'
  @homepage='http://libedit.sourceforge.net'
  @md5='252fbaa3812f0034715f7e78203897ec'

  def patches
    DATA
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    ENV.deparallelize # libedit Makefile doesn't support multiple make jobs
    system "make"
    system "make install"
  end
end

__END__
--- a/Makefile.in	2009-12-29 13:13:55.000000000 +0100
+++ b/Makefile.in	2009-12-29 13:14:26.000000000 +0100
@@ -100,7 +100,7 @@
 	ar -r $@ ${OOBJS}

 libedit.so: ${OOBJS}
-	${CC} --shared -o $@ ${OOBJS}
+	${CC} --shared -o $@ ${OOBJS} -lcurses -ltermcap

 # minimal dependency to make "make depend" optional
 editline.o editline.po editline.so editline.ln:	\

require 'formula'

class Bind <Formula
  @url='ftp://ftp.isc.org/isc/bind9/9.6.1-P2/bind-9.6.1-P2.tar.gz'
  @homepage='https://www.isc.org/software/bind'
  @md5='435bc2e26e470d46ddf2acb24abb6ea6'

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--sysconfdir=#{prefix}/etc",
                          "--localstatedir=#{prefix}/var"
    system "make install"
  end

  def caveats; <<-EOS
For Bind to work, you will need to do the following:

1) create configuration in #{prefix}/etc

2) If required by the configuration above, create a dovecot user and group

3) possibly create a launchd item in /Library/LaunchDaemons/org.isc.bind.plist, like so:
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
        "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>Label</key>
        <string>org.isc.bind</string>
        <key>ProgramArguments</key>
        <array>
                <string>#{sbin}/bind</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
</dict>
</plist>

4) start the server using: sudo launchctl load /Library/LaunchDaemons/org.isc.bind.plist
    EOS
  end
end

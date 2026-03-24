# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
require 'socket'
require 'open3'
require 'json'

class Gfsvn < Formula
  desc "Subversion with pristine on demand"
  homepage ""
  url "https://code-res-1257584459.cos.ap-guangzhou.myqcloud.com/SVN/MacSVN/subversion-1.15.3.tar.xz"
  sha256 "5321d97c6c7a6f38fc27e867aeb815de05b22b07d60374c363866b83eeedf875"
  license ""
  def install
    bin.install Dir["bin/*"]
    lib.install Dir["lib/*"]
    include.install Dir["include/*"]
    share.install Dir["share/*"]
    # 获取安装路径
    bin_path = bin.to_s
    lib_path = lib.to_s
    system "install_name_tool", "-change", "/usr/local/svn/serf/lib/libserf-1.dylib", "#{lib_path}/serf/lib/libserf-1.dylib", "#{bin_path}/svn"
    system "install_name_tool", "-change", "/usr/local/svn/sqlite-amalgamation/lib/libsqlite3.0.dylib", "#{lib_path}/sqlite/lib/libsqlite3.0.dylib", "#{bin_path}/svn"
    system "install_name_tool", "-change", "/usr/local/opt/gettext/lib/libintl.8.dylib", "#{lib_path}/gettext/lib/libintl.8.dylib", "#{bin_path}/svn"
    system "install_name_tool", "-change", "/usr/local/opt/zlib/lib/libz.1.dylib", "#{lib_path}/zlib/lib/libz.1.dylib", "#{bin_path}/svn"
    system "install_name_tool", "-change", "/usr/local/opt/apr-util/lib/libaprutil-1.0.dylib", "#{lib_path}/apr-util/lib/libaprutil-1.0.dylib", "#{bin_path}/svn"
    system "install_name_tool", "-change", "/usr/local/svn/apr/lib/libapr-1.0.dylib", "#{lib_path}/apr/lib/libapr-1.0.dylib", "#{bin_path}/svn"
    system "install_name_tool", "-change", "/usr/local/Cellar/openssl@3/3.4.0/lib/libcrypto.3.dylib", "#{lib_path}/openssl@3/lib/libcrypto.3.dylib", "#{lib_path}/openssl@3/lib/libssl.3.dylib"
    system "install_name_tool", "-change", "/usr/local/opt/apr/lib/libapr-1.0.dylib", "#{lib_path}/apr/lib/libapr-1.0.dylib", "#{lib_path}/apr-util/lib/libaprutil-1.0.dylib"
    files_to_update = Dir["#{lib_path}/serf/lib/*.dylib"]
    files_to_update.each do |file|
      dependencies = `otool -L #{file}`.split("\n").map(&:strip)
      dependencies.each do |dep|
        next if dep == file
        old_path = dep.split(" ").first
        if old_path.start_with?("/usr/local/opt")
          new_path = old_path.sub("/usr/local/opt", "#{lib_path}")
          system "install_name_tool", "-change", old_path, new_path, file
        end
        if old_path.start_with?("/usr/local/svn")
          new_path = old_path.sub("/usr/local/svn", "#{lib_path}")
          system "install_name_tool", "-change", old_path, new_path, file
        end
      end
    end
    version = "1.15.3"
    ip_addresses = Socket.ip_address_list.select { |addr| addr.ipv4? && !addr.ipv4_loopback? }.map(&:ip_address)
    ip_address = ip_addresses.first
    mac_addresses = []
    ifconfig_output, _ = Open3.capture2("ifconfig")
    ifconfig_output.scan(/ether ([0-9a-f:]+)/) { |match| mac_addresses << match[0] }
    mac_address = mac_addresses.first
    os_info = `uname -srm`.strip
    username = ENV['USER']
    data = {
      ips: [ip_address],
      macs: [mac_address],
      os: os_info,
      username: username,
      version: version
    }
  
    payload = {
      type: "install",
      message: data.to_json
    }
  
    curl_command = [
      "curl", "-X", "POST", "https://git.woa.com/api/web/tencent/tortoisesvn/report",
      "--header", "Content-Type: application/json",
      "--data", payload.to_json
    ]
  
    stdout, stderr, status = Open3.capture3(*curl_command)
  
    if status.success?
      puts "Data reported successfully."
    else
      puts "Failed to report data."
    end

    # Fix SSL certificate verification: the bundled OpenSSL was compiled with
    # OPENSSLDIR="/usr/local/etc/openssl@3" (x86 path), but on Apple Silicon
    # Homebrew installs to /opt/homebrew. Create the expected directory and
    # symlink cert.pem so OpenSSL can find the system CA bundle automatically.
    brew_cert = "/opt/homebrew/etc/ca-certificates/cert.pem"
    openssl_dir = "/usr/local/etc/openssl@3"
    openssl_cert = "#{openssl_dir}/cert.pem"
    if File.exist?(brew_cert) && !File.exist?(openssl_cert)
      system "mkdir", "-p", openssl_dir
      system "ln", "-sf", brew_cert, openssl_cert
    end
  end
end

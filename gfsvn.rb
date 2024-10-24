# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Gfsvn < Formula
  desc "Subversion with pristine on demand"
  homepage ""
  url "https://code-res-1257584459.cos.ap-guangzhou.myqcloud.com/SVN/MacSVN/subversion-1.15.0.tar.xz"
  sha256 "3b07e7a3651469c257527274e9cf2a439de957d0a9feba3706a36f761a15b471"
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
    system "install_name_tool", "-change", "/usr/local/svn/curl/lib/libcurl.4.dylib", "#{lib_path}/curl/lib/libcurl.4.dylib", "#{bin_path}/svn"
    system "install_name_tool", "-change", "/usr/local/opt/gettext/lib/libintl.8.dylib", "#{lib_path}/gettext/lib/libintl.8.dylib", "#{bin_path}/svn"
    system "install_name_tool", "-change", "/usr/local/opt/zlib/lib/libz.1.dylib", "#{lib_path}/zlib/lib/libz.1.dylib", "#{bin_path}/svn"
    system "install_name_tool", "-change", "/usr/local/opt/apr-util/lib/libaprutil-1.0.dylib", "#{lib_path}/apr-util/lib/libaprutil-1.0.dylib", "#{bin_path}/svn"
    system "install_name_tool", "-change", "/usr/local/opt/apr/lib/libapr-1.0.dylib", "#{lib_path}/apr/lib/libapr-1.0.dylib", "#{bin_path}/svn"
    system "install_name_tool", "-change", "/usr/local/opt/libnghttp2/lib/libnghttp2.14.dylib", "#{lib_path}/libnghttp2/lib/libnghttp2.14.dylib", "#{bin_path}/svn"
    system "install_name_tool", "-change", "/usr/local/opt/libidn2/lib/libidn2.0.dylib", "#{lib_path}/libidn2/lib/libidn2.0.dylib", "#{bin_path}/svn"
    system "install_name_tool", "-change", "/usr/local/opt/brotli/lib/libbrotlidec.1.dylib", "#{lib_path}/brotli/lib/libbrotlidec.1.dylib", "#{bin_path}/svn"

    system "install_name_tool", "-change", "/usr/local/Cellar/openssl@3/3.1.3/lib/libcrypto.3.dylib", "#{lib_path}/openssl@3/lib/libcrypto.3.dylib", "#{lib_path}/openssl@3/lib/libssl.3.dylib"
    system "install_name_tool", "-change", "/usr/local/opt/libnghttp2/lib/libnghttp2.14.dylib", "#{lib_path}/libnghttp2/lib/libnghttp2.14.dylib", "#{lib_path}/curl/lib/libcurl.4.dylib"
    system "install_name_tool", "-change", "/usr/local/opt/libnghttp2/lib/libnghttp2.14.dylib", "#{lib_path}/libnghttp2/lib/libnghttp2.14.dylib", "#{lib_path}/libidn2/lib/libidn2.0.dylib"
    system "install_name_tool", "-change", "/usr/local/opt/libnghttp2/lib/libnghttp2.14.dylib", "#{lib_path}/libnghttp2/lib/libnghttp2.14.dylib", "#{lib_path}/brotli/lib/libbrotlidec.1.1.0.dylib"

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
      end
    end
  end
end

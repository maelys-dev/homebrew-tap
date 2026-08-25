class MaelysWarden < Formula
  desc "Run commands through portable sandbox profiles; includes the C SDK"
  homepage "https://warden.maelys.dev"
  url "https://github.com/maelys-dev/maelys-warden/archive/refs/tags/v0.14.0.tar.gz"
  sha256 "ec455a002ec6f39103c9fc4df682607f82c6e85864a8c53798ac21f158b5a784"
  license all_of: ["MIT", "Apache-2.0"]
  revision 1

  on_macos do
    depends_on macos: :sequoia
  end

  resource "maelys-sandbox" do
    url "https://github.com/maelys-dev/maelys-sandbox/archive/refs/tags/v0.2.0.tar.gz"
    sha256 "d5399b88889be8eb6449890cb12c8e9b40d61a63cda12db411c3ab7dd14b13c3"
  end

  resource "maelys-netd" do
    url "https://github.com/maelys-dev/maelys-netd/archive/refs/tags/v0.6.1.tar.gz"
    sha256 "7c356e980d719d222b47e977623875680739b33769e1bd0ed429476f15b4184c"
  end

  resource "maelys-system" do
    url "https://github.com/maelys-dev/maelys-system.git",
        tag:      "v0.4.0",
        revision: "070dbd4a570799ec421b85b0990b57d4d220d293"
  end

  def install
    # Several install goals share recursively rebuilt dependency archives.
    # Homebrew exports parallel MAKEFLAGS, so serialize this multi-goal make.
    ENV.deparallelize
    sandbox = buildpath/"vendor/maelys-sandbox"
    netd = buildpath/"vendor/maelys-netd"
    system = buildpath/"vendor/maelys-system"
    resource("maelys-sandbox").stage sandbox
    resource("maelys-netd").stage netd
    resource("maelys-system").stage system
    system "make", "-C", sandbox, "install", "PREFIX=#{prefix}"
    system "make", "-C", netd, "install", "PREFIX=#{prefix}",
           "MAELYS_SYSTEM_DIR=#{system}"
    system "make", "install", "install-cli", "install-sandbox-adapter",
           "install-netd-adapter", "install-warden", "install-examples",
           "install-sdks", "PREFIX=#{prefix}",
           "MAELYS_SANDBOX_DIR=#{sandbox}", "MAELYS_SANDBOX_PINNED_ARCHIVE=1",
           "MAELYS_NETD_DIR=#{netd}", "MAELYS_NETD_PINNED_ARCHIVE=1",
           "MAELYS_SYSTEM_DIR=#{system}", "MAELYS_SYSTEM_PINNED_ARCHIVE=1"
  end

  test do
    (testpath/"smoke.c").write <<~EOS
      #include <maelys/warden.h>
      int main(void) {
        return MAELYS_WARDEN_ABI_VERSION == 1u ? 0 : 1;
      }
    EOS
    system ENV.cc, "smoke.c", "-I#{include}", "-L#{lib}",
           "-lmaelys-warden", "-lmaelys_sandbox_executor_adapter",
           "-lmaelys_executor_netd_adapter", "-lmaelys_executor",
           "-lmaelys_netd", "-lmaelys-sandbox", "-lmaelys-mir",
           "-lmaelys_sys", "-pthread", "-o", "smoke"
    system "./smoke"
    assert_equal version.to_s, shell_output("#{bin}/maelys-warden --version").strip
  end
end

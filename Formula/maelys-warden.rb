class MaelysWarden < Formula
  desc "Run commands through portable sandbox policy; includes the C SDK"
  homepage "https://warden.maelys.dev"
  url "https://github.com/maelys-dev/maelys-warden/archive/refs/tags/v0.27.0.tar.gz"
  sha256 "a3e8b5d39c530de1e5d0abe339ef1c9120617e30400c506243ea5a0c7582276f"
  license all_of: ["MIT", "Apache-2.0"]

  on_macos do
    depends_on macos: :sequoia
  end

  resource "maelys-sandbox-policy" do
    url "https://github.com/maelys-dev/maelys-sandbox-policy/archive/refs/tags/v0.3.0.tar.gz"
    sha256 "3b7ab1a3f7b476e7ce0a6959f506c0fac52c5ccc18e8360581032db88d051bf0"
  end

  resource "maelys-netd" do
    url "https://github.com/maelys-dev/maelys-netd/archive/refs/tags/v0.8.0.tar.gz"
    sha256 "e96ccd8892a72c4ce38f91147aa00c5af0a333849b10527b9bb04c341a237191"
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
    sandbox = buildpath/"vendor/maelys-sandbox-policy"
    netd = buildpath/"vendor/maelys-netd"
    system = buildpath/"vendor/maelys-system"
    resource("maelys-sandbox-policy").stage sandbox
    resource("maelys-netd").stage netd
    resource("maelys-system").stage system
    system "make", "-C", sandbox, "install", "PREFIX=#{prefix}"
    system "make", "-C", netd, "install", "PREFIX=#{prefix}",
           "MAELYS_SYSTEM_DIR=#{system}"
    system "make", "install", "install-cli", "install-warden-policy-adapter",
           "install-netd-adapter", "install-warden", "install-examples",
           "install-sdks", "PREFIX=#{prefix}",
           "MAELYS_SANDBOX_POLICY_DIR=#{sandbox}", "MAELYS_SANDBOX_POLICY_PINNED_ARCHIVE=1",
           "MAELYS_NETD_DIR=#{netd}", "MAELYS_NETD_PINNED_ARCHIVE=1",
           "MAELYS_SYSTEM_DIR=#{system}", "MAELYS_SYSTEM_PINNED_ARCHIVE=1"
  end

  test do
    (testpath/"smoke.c").write <<~EOS
      #include <maelys/warden.h>
      int main(void) {
        return MAELYS_WARDEN_ABI_VERSION == 3u ? 0 : 1;
      }
    EOS
    system ENV.cc, "smoke.c", "-I#{include}", "-L#{lib}",
           "-lmaelys-warden", "-lmaelys-warden-policy-adapter",
           "-lmaelys_executor_netd_adapter", "-lmaelys_executor",
           "-lmaelys_netd", "-lmaelys-sandbox-policy", "-lmaelys-mir",
           "-lmaelys_sys", "-pthread", "-o", "smoke"
    system "./smoke"
    assert_equal version.to_s, shell_output("#{bin}/maelys-warden --version").strip
  end
end

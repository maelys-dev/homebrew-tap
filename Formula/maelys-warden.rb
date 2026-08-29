# typed: strict
# frozen_string_literal: true

class MaelysWarden < Formula
  desc "Run commands through portable sandbox policy; includes the C SDK"
  homepage "https://warden.maelys.dev"
  url "https://github.com/maelys-dev/maelys-warden/archive/refs/tags/v0.35.0.tar.gz"
  sha256 "dd7e3fd8cbb8550a0f6648d7547442e4b365e9e8288c9818a8fcac67b3eca036"
  license all_of: ["MIT", "Apache-2.0"]

  bottle do
    root_url "https://github.com/maelys-dev/maelys-warden/releases/download/v0.35.0"
    sha256 cellar: :any, arm64_sequoia: "dce677dfedd4d7f148a4a5685846c416fbaca79f892e60d9e0482aba45ed75c2"
    sha256 cellar: :any, arm64_tahoe:   "865cd2736594b7eb9fb7ea1ad50e4c84586f87c98d20e088e4b5d98eb8db2613"
  end

  on_macos do
    depends_on macos: :sequoia
  end

  resource "maelys-sandbox-policy" do
    url "https://github.com/maelys-dev/maelys-sandbox-policy/archive/refs/tags/v0.4.0.tar.gz"
    sha256 "f22165ed16566f328cb06b3f1540ef23d074b8319361fb2240dace9b55ccc0f9"
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
        return MAELYS_WARDEN_ABI_VERSION == 4u ? 0 : 1;
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

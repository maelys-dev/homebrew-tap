# typed: strict
# frozen_string_literal: true

class MaelysWarden < Formula
  desc "Run commands through portable sandbox policy; includes the C SDK"
  homepage "https://warden.maelys.dev"
  url "https://github.com/maelys-dev/maelys-warden/archive/refs/tags/v0.39.1.tar.gz"
  version "0.39.1"
  sha256 "b5b3d83036c53db0a7e2653b2c8fd8d7dd75745a5bee7281db40a47ed9a1afc4"
  license all_of: ["MIT", "Apache-2.0"]

  bottle do
    root_url "https://github.com/maelys-dev/maelys-warden/releases/download/v0.39.1"
    sha256 cellar: :any, arm64_sequoia: "095a8dd8171b2de85d4f5628080e796e8e88cde2f834c85df056813270afa036"
    sha256 cellar: :any, arm64_tahoe:   "a55947c0dd3157f947e4ebfa24714423e56acab3eb47dce15bf624029e44d33f"
  end

  on_macos do
    depends_on macos: :sequoia
  end

  resource "maelys-sandbox-policy" do
    url "https://github.com/maelys-dev/maelys-sandbox-policy/archive/refs/tags/v0.4.0.tar.gz"
    sha256 "f22165ed16566f328cb06b3f1540ef23d074b8319361fb2240dace9b55ccc0f9"
  end

  resource "maelys-egress" do
    url "https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.10.0.tar.gz"
    sha256 "9c7c8965d52e7c4a07204177799cebbb7de9b95c7e951019274fb2204aa68cb0"
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
    egress = buildpath/"vendor/maelys-egress"
    system = buildpath/"vendor/maelys-system"
    resource("maelys-sandbox-policy").stage sandbox
    resource("maelys-egress").stage egress
    resource("maelys-system").stage system
    system "make", "-C", sandbox, "install", "PREFIX=#{prefix}"
    system "make", "-C", egress, "install", "PREFIX=#{prefix}",
           "MAELYS_SYSTEM_DIR=#{system}"
    system "make", "install", "install-cli", "install-warden-policy-adapter",
           "install-egress-adapter", "install-warden", "install-examples",
           "install-sdks", "PREFIX=#{prefix}",
           "MAELYS_SANDBOX_POLICY_DIR=#{sandbox}", "MAELYS_SANDBOX_POLICY_PINNED_ARCHIVE=1",
           "MAELYS_EGRESS_DIR=#{egress}", "MAELYS_EGRESS_PINNED_ARCHIVE=1",
           "MAELYS_SYSTEM_DIR=#{system}", "MAELYS_SYSTEM_PINNED_ARCHIVE=1"
  end

  test do
    (testpath/"smoke.c").write <<~EOS
      #include <maelys/warden.h>
      int main(void) {
        return MAELYS_WARDEN_ABI_VERSION == 7u ? 0 : 1;
      }
    EOS
    system ENV.cc, "smoke.c", "-I#{include}", "-L#{lib}",
           "-lmaelys-warden", "-lmaelys-warden-policy-adapter",
           "-lmaelys_executor_egress_adapter", "-lmaelys_executor",
           "-lmaelys_egress", "-lmaelys-sandbox-policy", "-lmaelys-mir",
           "-lmaelys_sys", "-pthread", "-o", "smoke"
    system "./smoke"
    assert_equal version.to_s, shell_output("#{bin}/maelys-warden --version").strip
  end
end

# typed: strict
# frozen_string_literal: true

class MaelysWarden < Formula
  desc "Run commands through portable sandbox policy; includes the C SDK"
  homepage "https://warden.maelys.dev"
  url "https://github.com/maelys-dev/maelys-warden/releases/download/v1.0.0/maelys-warden-1.0.0-source.tar.gz"
  version "1.0.0"
  sha256 "a3fa8ae20dd2a94902db07a6470f93fae020455b819e64fb7f70faaf06d0a2e1"
  license all_of: ["MPL-2.0", "Apache-2.0"]

  bottle do
    root_url "https://github.com/maelys-dev/maelys-warden/releases/download/v1.0.0"
    sha256 cellar: :any, arm64_sequoia: "ce2b683670e962532287112405a0d07b1ef8d8dd6fb658fb784db305e81ea715"
    sha256 cellar: :any, arm64_tahoe:   "87278479f3696556d6cf9009060e410e9a497245451c53c4d62e226272ce730c"
  end

  on_macos do
    depends_on macos: :sequoia
  end

  resource "maelys-sandbox-policy" do
    url "https://github.com/maelys-dev/maelys-sandbox-policy/archive/refs/tags/v0.4.0.tar.gz"
    sha256 "f22165ed16566f328cb06b3f1540ef23d074b8319361fb2240dace9b55ccc0f9"
  end

  resource "maelys-egress" do
    url "https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.10.1.tar.gz"
    sha256 "5c620220f1d7fbebd9d138435bfcce8e4b33584f6a2346cba27a5f045e1a1cec"
  end

  resource "maelys-system" do
    url "https://github.com/maelys-dev/maelys-system.git",
        tag:      "v0.5.0",
        revision: "c1fa1d4ebf1a33f084239d55af565150d5e51e13"
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

# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release from this template: 0.19.0, https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.19.0.tar.gz and
# 1f32d0dbc25ca3b89f3291d54874183d9e12ea75bbcea41a9c47acac96807749 are replaced with the released source archive of one tag. The
# pinned maelys-cli below is copied from dependencies/maelys-cli.pin of that
# tag by scripts/render-homebrew-formula.sh.
class MaelysEgress < Formula
  desc "Policy-enforced HTTP CONNECT and SOCKS5 network mediator in pure C"
  homepage "https://github.com/maelys-dev/maelys-egress"
  url "https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.19.0.tar.gz"
  sha256 "1f32d0dbc25ca3b89f3291d54874183d9e12ea75bbcea41a9c47acac96807749"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-egress/releases/download/v0.19.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "3e3882a862a78c749bc3c430e45dd1736953f2a40705de805d55a81100cc8f72"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "89ef40d8ec3f22ffb2af218438b8f354ace26cd8ae9be483e1fd0ebe6c06b058"
  end

  depends_on "python@3.13" => :build
  depends_on "libmaelys-sys"

  resource "maelys-cli" do
    url "https://github.com/maelys-dev/maelys-cli.git",
        tag:      "v0.5.19",
        revision: "6868bd13cfdccc0cdf59f40174f2bdc76f57bd04"
  end

  def install
    # The Makefile verifies the installed Maelys System against the version
    # recorded in dependencies/maelys-system.pin and the maelys-cli checkout
    # against dependencies/maelys-cli.pin, then installs libmaelys_egress, its
    # headers, the pkg-config file, the daemon, the documentation and the
    # manifest that registers `maelys egress`.
    ENV.deparallelize
    cli_dir = buildpath/"vendor/maelys-cli"
    resource("maelys-cli").stage cli_dir
    system "make", "install", "PREFIX=#{prefix}",
           "MAELYS_SYSTEM_PREFIX=#{formula_opt_prefix("libmaelys-sys")}",
           "MAELYS_CLI_DIR=#{cli_dir}"
  end

  test do
    assert_equal "maelys-egress #{version}",
                 shell_output("#{bin}/maelys-egress version").strip
    sys = Formula["libmaelys-sys"]
    (testpath/"smoke.c").write <<~EOS
      #include <maelys/egress.h>
      int main(void) { return MAELYS_EGRESS_ABI_VERSION == 2u ? 0 : 1; }
    EOS
    system ENV.cc, "-std=c11", "smoke.c", "-I#{include}", "-I#{sys.opt_include}",
           "-L#{lib}", "-L#{sys.opt_lib}", "-lmaelys_egress", "-lmaelys_sys",
           "-pthread", "-o", "smoke"
    system "./smoke"
    manifest = (share/"maelys/commands/egress.json").read
    assert_match "\"executable\": \"#{opt_bin}/maelys-egress\"", manifest
    (testpath/"egress.conf").write <<~EOS
      schema_version = 1
      listen = 127.0.0.1:0
      unauthenticated_loopback = true
      allow_private = 127.0.0.1:9
    EOS
    chmod 0600, testpath/"egress.conf"
    validate = "#{bin}/maelys-egress config validate --config #{testpath}/egress.conf"
    assert_match '"valid":true', shell_output("#{validate} --format json --compact")
  end
end

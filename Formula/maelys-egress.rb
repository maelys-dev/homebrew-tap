# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release from this template: 0.16.0, https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.16.0.tar.gz and
# e79f0f0e7497101653f61b1fb1ebb3147320e7113a0007d58583b27c014467bd are replaced with the released source archive of one tag. The
# pinned maelys-cli below is copied from adapter/MAELYS_CLI_PIN of that tag
# by scripts/render-homebrew-formula.sh.
class MaelysEgress < Formula
  desc "Policy-enforced HTTP CONNECT and SOCKS5 network mediator in pure C"
  homepage "https://github.com/maelys-dev/maelys-egress"
  url "https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.16.0.tar.gz"
  sha256 "e79f0f0e7497101653f61b1fb1ebb3147320e7113a0007d58583b27c014467bd"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-egress/releases/download/v0.16.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "f77d7bf58b206d26faeb4467a821915b33207a80102cef3d91dd3dc692158b24"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c72777010807d59dfb6030c42b8cc2047154e4450dcbacee70cd9cd1bf47f9a4"
  end

  depends_on "python@3.13" => :build
  depends_on "libmaelys-sys"

  resource "maelys-cli" do
    url "https://github.com/maelys-dev/maelys-cli.git",
        tag:      "v0.5.11",
        revision: "e347740560480da1b09f8fee6c028b4f7d1b6c03"
  end

  def install
    # The Makefile verifies the installed Maelys System against the version
    # recorded in adapter/MAELYS_SYSTEM_PIN and the maelys-cli checkout
    # against adapter/MAELYS_CLI_PIN, then installs libmaelys_egress, its
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

# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release from this template: 0.13.1, https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.13.1.tar.gz and
# bcd383085e6e942cca1e9615754a1a3e1534832ee9e19b579211791d508d5755 are replaced with the released source archive of one tag. The
# pinned maelys-cli below is copied from adapter/MAELYS_CLI_PIN of that tag
# by scripts/render-homebrew-formula.sh.
class MaelysEgress < Formula
  desc "Policy-enforced HTTP CONNECT and SOCKS5 network mediator in pure C"
  homepage "https://github.com/maelys-dev/maelys-egress"
  url "https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.13.1.tar.gz"
  sha256 "bcd383085e6e942cca1e9615754a1a3e1534832ee9e19b579211791d508d5755"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-egress/releases/download/v0.13.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "6120692fcd46b35ce05372de52287d05e658bdf963d2a77a4ce6c2ea1e6cbdeb"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "1d66e28aaf7053b7576f1b2184ff572c698f37645ca038c609929e4853d5d88f"
  end

  depends_on "python@3.13" => :build
  depends_on "libmaelys-sys"

  resource "maelys-cli" do
    url "https://github.com/maelys-dev/maelys-cli.git",
        tag:      "v0.5.1",
        revision: "193786914f19f2f42b12815a267ba2d4ff8a6f3a"
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

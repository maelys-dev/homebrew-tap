# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release from this template: 0.15.0, https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.15.0.tar.gz and
# 3adf486498e834edcb5310bfc60c19d37fbb92f747aab6b130d877628911b63a are replaced with the released source archive of one tag. The
# pinned maelys-cli below is copied from adapter/MAELYS_CLI_PIN of that tag
# by scripts/render-homebrew-formula.sh.
class MaelysEgress < Formula
  desc "Policy-enforced HTTP CONNECT and SOCKS5 network mediator in pure C"
  homepage "https://github.com/maelys-dev/maelys-egress"
  url "https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.15.0.tar.gz"
  sha256 "3adf486498e834edcb5310bfc60c19d37fbb92f747aab6b130d877628911b63a"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-egress/releases/download/v0.15.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d8b7028398517dded662eb0ccc07b8238ebbd685fbc9053349ca04e4108dfa40"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0b8df717a699fcb11baf9fddb52e9caffba8e63f6c400ff549375678d07e0c36"
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

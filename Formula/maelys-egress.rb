# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release from this template: 0.27.1, https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.27.1.tar.gz and
# d1465cb5927be308f3fa64c0c58908842deaeaaac013b9342a2536a6e58bd343 are replaced with the released source archive of one tag. The
# pinned maelys-cli below is copied from dependencies/maelys-cli.pin of that
# tag by scripts/render-homebrew-formula.sh.
class MaelysEgress < Formula
  desc "Policy-enforced HTTP CONNECT and SOCKS5 network mediator in pure C"
  homepage "https://github.com/maelys-dev/maelys-egress"
  url "https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.27.1.tar.gz"
  sha256 "d1465cb5927be308f3fa64c0c58908842deaeaaac013b9342a2536a6e58bd343"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-egress/releases/download/v0.27.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "b9f1ed2c9bc48c0203a56752477219ced42dd094c120def8f764c441d9d6b24c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ff4c18e347152762f11b0afb9c1fac81fa6078e92d35e417465a8813a4623829"
  end

  depends_on "python@3.13" => :build
  depends_on "libmaelys-sys"

  resource "maelys-cli" do
    url "https://github.com/maelys-dev/maelys-cli.git",
        tag:      "v0.5.33",
        revision: "fb22dda2c3db9ce9606f1610fd5c83465566874c"
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
      int main(void) { return MAELYS_EGRESS_ABI_COMPATIBLE_SINCE <= 3u && 3u <= MAELYS_EGRESS_ABI_VERSION ? 0 : 1; }
    EOS
    system ENV.cc, "-std=c11", "smoke.c", "-I#{include}", "-I#{sys.opt_include}",
           "-L#{lib}", "-L#{sys.opt_lib}", "-lmaelys_egress", "-lmaelys_sys",
           "-pthread", "-o", "smoke"
    system "./smoke"
    (testpath/"client-smoke.c").write <<~EOS
      #include <maelys/egress_client.h>
      int main(void) { return maelys_egress_client_abi_compatible_since() <= 1u && 1u <= maelys_egress_client_abi_version() ? 0 : 1; }
    EOS
    system ENV.cc, "-std=c11", "client-smoke.c", "-I#{include}", "-L#{lib}",
           "-lmaelys_egress_client", "-o", "client-smoke"
    system "./client-smoke"
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

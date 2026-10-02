# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release from this template: 0.26.0, https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.26.0.tar.gz and
# c3d142a7e958b71f4541fa462c4fdcce05f91d99581a26628ae1bfb540d1897f are replaced with the released source archive of one tag. The
# pinned maelys-cli below is copied from dependencies/maelys-cli.pin of that
# tag by scripts/render-homebrew-formula.sh.
class MaelysEgress < Formula
  desc "Policy-enforced HTTP CONNECT and SOCKS5 network mediator in pure C"
  homepage "https://github.com/maelys-dev/maelys-egress"
  url "https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.26.0.tar.gz"
  sha256 "c3d142a7e958b71f4541fa462c4fdcce05f91d99581a26628ae1bfb540d1897f"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-egress/releases/download/v0.26.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "b3a5cd11053a8f033e540c968a4b485a04c2c4272d8842dc4963da767a00d830"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0620184c4961c8cec003f804e61fc9c575a95cbdd7c604d2623bf2445a7f7817"
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

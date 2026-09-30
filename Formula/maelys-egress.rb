# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release from this template: 0.22.5, https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.22.5.tar.gz and
# 88fdbf5b0343e23d154702639eb41342d3e59e5534bf07e1bd55e8155d411a21 are replaced with the released source archive of one tag. The
# pinned maelys-cli below is copied from dependencies/maelys-cli.pin of that
# tag by scripts/render-homebrew-formula.sh.
class MaelysEgress < Formula
  desc "Policy-enforced HTTP CONNECT and SOCKS5 network mediator in pure C"
  homepage "https://github.com/maelys-dev/maelys-egress"
  url "https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.22.5.tar.gz"
  sha256 "88fdbf5b0343e23d154702639eb41342d3e59e5534bf07e1bd55e8155d411a21"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-egress/releases/download/v0.22.5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "593142fd2d561b54af34314579b8eb884f4bef456ff57f008f8ea66e23d68e70"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "260de594049701e4a704d1c2c964394030bf4a76548122cfdc3d5978895eccd5"
  end

  depends_on "python@3.13" => :build
  depends_on "libmaelys-sys"

  resource "maelys-cli" do
    url "https://github.com/maelys-dev/maelys-cli.git",
        tag:      "v0.5.30",
        revision: "da330c75c21daf8a03e42227012e20a4f9592549"
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
      int main(void) { return MAELYS_EGRESS_ABI_VERSION == 3u ? 0 : 1; }
    EOS
    system ENV.cc, "-std=c11", "smoke.c", "-I#{include}", "-I#{sys.opt_include}",
           "-L#{lib}", "-L#{sys.opt_lib}", "-lmaelys_egress", "-lmaelys_sys",
           "-pthread", "-o", "smoke"
    system "./smoke"
    (testpath/"client-smoke.c").write <<~EOS
      #include <maelys/egress_client.h>
      int main(void) { return maelys_egress_client_abi_version() == 1u ? 0 : 1; }
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

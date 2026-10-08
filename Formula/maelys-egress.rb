# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release from this template: 0.30.1, https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.30.1.tar.gz and
# b23fb6bfad3581ad071d7b2644cbe4baa84c8e9eecbab9e894373742a0c46147 are replaced with the released source archive of one tag. The
# pinned maelys-cli below is copied from dependencies/maelys-cli.pin of that
# tag by scripts/render-homebrew-formula.sh.
class MaelysEgress < Formula
  desc "Policy-enforced HTTP CONNECT and SOCKS5 network mediator in pure C"
  homepage "https://github.com/maelys-dev/maelys-egress"
  url "https://github.com/maelys-dev/maelys-egress/archive/refs/tags/v0.30.1.tar.gz"
  sha256 "b23fb6bfad3581ad071d7b2644cbe4baa84c8e9eecbab9e894373742a0c46147"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-egress/releases/download/v0.30.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "4d3abe6f4984c672c5ea5b4de5b4eed91f1696a5a429c685a1895267f2236fc8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "6fd48eb0a51781b1d70a92cbb9cd40037af310d5715521358f44a4e19d627c5d"
  end

  depends_on "python@3.13" => :build
  depends_on "libmaelys-sys"

  resource "maelys-cli" do
    url "https://github.com/maelys-dev/maelys-cli.git",
        tag:      "v0.6.2",
        revision: "91145f61c2484e7dfa1b2877b8850bad105e56e6"
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
    # The manifest names the binary of this keg, where `make install` put it,
    # and carries that binary's digest: the two things the maelys dispatcher
    # checks before it runs `maelys egress`.
    manifest = (share/"maelys/commands/egress.json").read
    digest = (bin/"maelys-egress").sha256
    assert_match "\"executable\": \"#{bin}/maelys-egress\"", manifest
    assert_match "\"sha256\": \"#{digest}\"", manifest
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

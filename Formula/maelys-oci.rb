# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release from this template: 0.9.7, https://github.com/maelys-dev/maelys-oci/archive/refs/tags/v0.9.7.tar.gz and
# 75ab95167607ab59ca475a4e9404cd142356d00d1af2286108f6f10d5f09b778 are replaced with the source archive of one tag, v0.6.4 and
# 04a312e359a60aefafb9e40df4dcfa1a48e2507e with dependencies/maelys-cli.pin of that tag, by
# scripts/render-homebrew-formula.sh. The Maelys libraries are linked into
# the terminal, so the tap's libmaelys-sys, libmaelys-json and libmaelys-http
# formulas are build dependencies: the Makefile verifies each against the ABI
# this tree was written for and the version the tag pins.
class MaelysOci < Formula
  desc "Bounded OCI acquisition, canonical materialization and immutable artifact store"
  homepage "https://github.com/maelys-dev/maelys-oci"
  url "https://github.com/maelys-dev/maelys-oci/archive/refs/tags/v0.9.7.tar.gz"
  sha256 "75ab95167607ab59ca475a4e9404cd142356d00d1af2286108f6f10d5f09b778"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-oci/releases/download/v0.9.7"
    sha256 arm64_tahoe:   "db118258a5dff42ccb9bdbb6a0ccb6a417d0ff2495e99beb488dcbe5f1157df6"
    sha256 arm64_sequoia: "78eebebd0f0f53932474a0cc0f470030b5bad37309889cdf4f016fe7d2e60b53"
  end

  depends_on "libmaelys-http" => :build
  depends_on "libmaelys-json" => :build
  depends_on "libmaelys-sys" => :build
  depends_on "pkgconf" => :build
  depends_on "python@3.13" => :build
  depends_on "e2fsprogs"
  depends_on "libarchive"
  depends_on "mbedtls"

  resource "maelys-cli" do
    url "https://github.com/maelys-dev/maelys-cli.git",
        tag:      "v0.6.4",
        revision: "04a312e359a60aefafb9e40df4dcfa1a48e2507e"
  end

  def install
    cli_dir = buildpath/"vendor/maelys-cli"
    resource("maelys-cli").stage cli_dir
    # The terminal, the manifest that registers `maelys oci` with the
    # dispatcher of the maelys formula, and the shell completions. Homebrew
    # rewrites the library paths of the binary and signs it again after this
    # step, when it bottles and when it pours: a digest taken by the build
    # would name other bytes than those installed, and the dispatcher would
    # refuse its whole catalog. The manifest declares none.
    system "make", "install-command", "PREFIX=#{prefix}", "MANIFEST_DIGEST=omitted",
           "MAELYS_SYSTEM_PREFIX=#{formula_opt_prefix("libmaelys-sys")}",
           "MAELYS_JSON_PREFIX=#{formula_opt_prefix("libmaelys-json")}",
           "MAELYS_HTTP_PREFIX=#{formula_opt_prefix("libmaelys-http")}",
           "MAELYS_CLI_DIR=#{cli_dir}",
           "PKG_CONFIG_PATH=#{formula_opt_lib("libarchive")}/pkgconfig:#{formula_opt_lib("e2fsprogs")}/pkgconfig"
  end

  test do
    assert_equal "maelys-oci #{version}",
                 shell_output("#{bin}/maelys-oci version").strip
    summary = shell_output("#{bin}/maelys-oci describe --summary --format json --compact --non-interactive")
    assert_match(%r{"contract":"agent-cli/v2"}, summary)
    # What the dispatcher judges: the executable the manifest names, and a
    # digest that is either absent or that of the binary as installed.
    manifest = JSON.parse((share/"maelys/commands/oci.json").read)
    assert_equal (prefix/"bin/maelys-oci").to_s, manifest["executable"]
    declared = manifest.fetch("sha256", (bin/"maelys-oci").sha256)
    assert_equal (bin/"maelys-oci").sha256, declared
  end
end

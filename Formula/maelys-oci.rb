# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release from this template: 0.6.3, https://github.com/maelys-dev/maelys-oci/archive/refs/tags/v0.6.3.tar.gz and
# d1240f5a4bae6a5b472e6b250efd57079188047f6f4f7153fc36151f779849d0 are replaced with the source archive of one tag, v0.5.25 and
# 4f8a4236e503341a53cd98747fa6116a320675fe with dependencies/maelys-cli.pin of that tag, by
# scripts/render-homebrew-formula.sh. The Maelys libraries are linked into
# the terminal, so the tap's libmaelys-sys, libmaelys-json and libmaelys-http
# formulas are build dependencies: the Makefile verifies each against the ABI
# this tree was written for and the version the tag pins.
class MaelysOci < Formula
  desc "Bounded OCI acquisition, canonical materialization and immutable artifact store"
  homepage "https://github.com/maelys-dev/maelys-oci"
  url "https://github.com/maelys-dev/maelys-oci/archive/refs/tags/v0.6.3.tar.gz"
  sha256 "d1240f5a4bae6a5b472e6b250efd57079188047f6f4f7153fc36151f779849d0"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-oci/releases/download/v0.6.3"
    sha256 arm64_tahoe:   "9cb3081fa93296063edb0c1da8ac5bee526de1de148f4eb4d2c28ee238e12d41"
    sha256 arm64_sequoia: "84fe0672f691b0d97c85b131f23e9f04a9efbb589d029e73d769ead71fc672c4"
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
        tag:      "v0.5.25",
        revision: "4f8a4236e503341a53cd98747fa6116a320675fe"
  end

  def install
    cli_dir = buildpath/"vendor/maelys-cli"
    resource("maelys-cli").stage cli_dir
    # The terminal, the manifest that registers `maelys oci` with the
    # dispatcher of the maelys formula, and the shell completions.
    system "make", "install-command", "PREFIX=#{prefix}",
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
    manifest = share/"maelys/commands/oci.json"
    assert_match bin/"maelys-oci", manifest.read
  end
end

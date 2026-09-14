# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release from this template: 0.6.5, https://github.com/maelys-dev/maelys-oci/archive/refs/tags/v0.6.5.tar.gz and
# 2026563f485ec8f697fe0b29c0e48d8a82b5ce852a3679cf0f8a836617ba2e6a are replaced with the source archive of one tag, v0.5.25 and
# 4f8a4236e503341a53cd98747fa6116a320675fe with dependencies/maelys-cli.pin of that tag, by
# scripts/render-homebrew-formula.sh. The Maelys libraries are linked into
# the terminal, so the tap's libmaelys-sys, libmaelys-json and libmaelys-http
# formulas are build dependencies: the Makefile verifies each against the ABI
# this tree was written for and the version the tag pins.
class MaelysOci < Formula
  desc "Bounded OCI acquisition, canonical materialization and immutable artifact store"
  homepage "https://github.com/maelys-dev/maelys-oci"
  url "https://github.com/maelys-dev/maelys-oci/archive/refs/tags/v0.6.5.tar.gz"
  sha256 "2026563f485ec8f697fe0b29c0e48d8a82b5ce852a3679cf0f8a836617ba2e6a"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-oci/releases/download/v0.6.5"
    sha256 arm64_tahoe:   "3eb436ff23ffcb54548ff4accfa10cc14716b442670a2b6924002759528dcf72"
    sha256 arm64_sequoia: "d0a57b41ff1335c2e55987e19fbff3d4d7825e38abe372943c7d447d2e3214e3"
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

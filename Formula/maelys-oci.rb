# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release from this template: 0.7.1, https://github.com/maelys-dev/maelys-oci/archive/refs/tags/v0.7.1.tar.gz and
# c3236c9751ab469c0ddc57ff262a4b2fec98f2d5dca3db8911e11b3c0ff13081 are replaced with the source archive of one tag, v0.5.30 and
# da330c75c21daf8a03e42227012e20a4f9592549 with dependencies/maelys-cli.pin of that tag, by
# scripts/render-homebrew-formula.sh. The Maelys libraries are linked into
# the terminal, so the tap's libmaelys-sys, libmaelys-json and libmaelys-http
# formulas are build dependencies: the Makefile verifies each against the ABI
# this tree was written for and the version the tag pins.
class MaelysOci < Formula
  desc "Bounded OCI acquisition, canonical materialization and immutable artifact store"
  homepage "https://github.com/maelys-dev/maelys-oci"
  url "https://github.com/maelys-dev/maelys-oci/archive/refs/tags/v0.7.1.tar.gz"
  sha256 "c3236c9751ab469c0ddc57ff262a4b2fec98f2d5dca3db8911e11b3c0ff13081"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-oci/releases/download/v0.7.1"
    sha256 arm64_tahoe:   "67aca8052ae2e954a9091594bd92b7c813d86afb6e37873e7cf4d2b912e85d4f"
    sha256 arm64_sequoia: "7d59a4428ad48d6848eed1a6b7c670f6de2dad288172b4e02ec73d5dd2674ef2"
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
        tag:      "v0.5.30",
        revision: "da330c75c21daf8a03e42227012e20a4f9592549"
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

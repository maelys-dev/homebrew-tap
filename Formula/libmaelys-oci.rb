# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release from this template: 0.9.4, https://github.com/maelys-dev/maelys-oci/archive/refs/tags/v0.9.4.tar.gz and
# aa5c50e5f1bb244903ddaa3a746f52b408a64751e2be66ebcb5730af01269d31 are replaced with the source archive of one tag, v0.6.0 and
# 85964ae983a76660f7b2e4f45e74c8958648250c with dependencies/maelys-cli.pin of that tag, by
# scripts/render-homebrew-formula.sh. Maelys System, JSON and HTTP come from
# the tap's libmaelys-sys, libmaelys-json and libmaelys-http formulas: the
# Makefile verifies each installed library against the ABI this tree was
# written for and the version the tag pins, and refuses an older one.
class LibmaelysOci < Formula
  desc "Bounded OCI acquisition, canonical materialization and immutable artifact store"
  homepage "https://github.com/maelys-dev/maelys-oci"
  url "https://github.com/maelys-dev/maelys-oci/archive/refs/tags/v0.9.4.tar.gz"
  sha256 "aa5c50e5f1bb244903ddaa3a746f52b408a64751e2be66ebcb5730af01269d31"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-oci/releases/download/v0.9.4"
    sha256 arm64_tahoe:   "f904b95c910ae8ba0cdfddf02aa106c7d09c01504072b79e6cb2e09d9c96261e"
    sha256 arm64_sequoia: "4f2dc72d6a3a1e4cc96062d2e19532fc62f94727b91bf0c48c65064e80b66fdd"
  end

  depends_on "pkgconf" => :build
  depends_on "python@3.13" => :build
  depends_on "e2fsprogs"
  depends_on "libarchive"
  depends_on "libmaelys-http"
  depends_on "libmaelys-json"
  depends_on "libmaelys-sys"
  depends_on "mbedtls"

  # The framework is linked into the terminal, which the build produces to
  # bind the pkg-config file to it; this formula installs neither.
  resource "maelys-cli" do
    url "https://github.com/maelys-dev/maelys-cli.git",
        tag:      "v0.6.0",
        revision: "85964ae983a76660f7b2e4f45e74c8958648250c"
  end

  def install
    cli_dir = buildpath/"vendor/maelys-cli"
    resource("maelys-cli").stage cli_dir
    system "make", "install-library", "PREFIX=#{prefix}",
           "MAELYS_SYSTEM_PREFIX=#{formula_opt_prefix("libmaelys-sys")}",
           "MAELYS_JSON_PREFIX=#{formula_opt_prefix("libmaelys-json")}",
           "MAELYS_HTTP_PREFIX=#{formula_opt_prefix("libmaelys-http")}",
           "MAELYS_CLI_DIR=#{cli_dir}",
           "PKG_CONFIG_PATH=#{formula_opt_lib("libarchive")}/pkgconfig:#{formula_opt_lib("e2fsprogs")}/pkgconfig"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <maelys/oci.h>
      int main(void) {
        return maelys_oci_platform_valid("linux/amd64") ? 0 : 1;
      }
    EOS
    # libarchive and e2fsprogs are keg-only: the pkg-config file names them
    # in Requires.private, so their files must be on the path.
    ENV.prepend_path "PKG_CONFIG_PATH", lib/"pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", formula_opt_lib("libarchive")/"pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", formula_opt_lib("e2fsprogs")/"pkgconfig"
    flags = shell_output("pkg-config --static --cflags --libs maelys-oci").split
    system ENV.cc, "-std=c11", testpath/"test.c", *flags, "-o", testpath/"test"
    system testpath/"test"
  end
end

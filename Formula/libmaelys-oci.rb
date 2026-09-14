# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release from this template: 0.6.5, https://github.com/maelys-dev/maelys-oci/archive/refs/tags/v0.6.5.tar.gz and
# 2026563f485ec8f697fe0b29c0e48d8a82b5ce852a3679cf0f8a836617ba2e6a are replaced with the source archive of one tag, v0.5.25 and
# 4f8a4236e503341a53cd98747fa6116a320675fe with dependencies/maelys-cli.pin of that tag, by
# scripts/render-homebrew-formula.sh. Maelys System, JSON and HTTP come from
# the tap's libmaelys-sys, libmaelys-json and libmaelys-http formulas: the
# Makefile verifies each installed library against the ABI this tree was
# written for and the version the tag pins, and refuses an older one.
class LibmaelysOci < Formula
  desc "Bounded OCI acquisition, canonical materialization and immutable artifact store"
  homepage "https://github.com/maelys-dev/maelys-oci"
  url "https://github.com/maelys-dev/maelys-oci/archive/refs/tags/v0.6.5.tar.gz"
  sha256 "2026563f485ec8f697fe0b29c0e48d8a82b5ce852a3679cf0f8a836617ba2e6a"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-oci/releases/download/v0.6.5"
    sha256 arm64_tahoe:   "48be64d00812db25fb676ad92295d00df4768597aed721e43b28b73dd4915b29"
    sha256 arm64_sequoia: "4e15c36a7c2ca0dfafb35d073dbf014b902df040ae4d1678926365c54b90c9db"
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
        tag:      "v0.5.25",
        revision: "4f8a4236e503341a53cd98747fa6116a320675fe"
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

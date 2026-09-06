# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag. Installs the framework
# to build a Maelys command-line product: libraries, headers, pkg-config
# files, the schema embedding tool, the reference generator, agent texts
# and templates. The `maelys` command itself is the `maelys` formula.
class LibmaelysCli < Formula
  desc "Framework and tools to build a Maelys command-line product"
  homepage "https://github.com/maelys-dev/maelys-cli"
  url "https://github.com/maelys-dev/maelys-cli/archive/refs/tags/v0.5.18.tar.gz"
  sha256 "b306e5171ed00ad5081f9786b4ee7923d57fe8e133f498903c1e2c09c7de76f4"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-cli/releases/download/v0.5.18"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "fb0eb7e75dbae9fb6fc2882b41124af302d06bdba495b1f900494d5c6da6ebf0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "6d2b5ec6469474f91e57c6f7a2be9e1e2df884f1de30bd87e63df807bf1aed9f"
  end

  depends_on "libmaelys-json"
  depends_on "python@3.13"

  def install
    json = Formula["libmaelys-json"]
    system "make", "install-sdk", "PREFIX=#{prefix}", "CC=#{ENV.cc}",
           "MAELYS_JSON_CFLAGS=-I#{json.opt_include}",
           "MAELYS_JSON_LIB=#{json.opt_lib}/libmaelys-json.a",
           "MAELYS_JSON_LIBS=#{json.opt_lib}/libmaelys-json.a"
  end

  test do
    (testpath/"smoke.c").write <<~EOS
      #include <maelys/cli.h>
      int main(void) {
        maelys_cli_json_writer_t writer;
        maelys_cli_json_writer_init(&writer);
        return maelys_cli_json_begin_object(&writer) == 0 &&
               maelys_cli_json_end_object(&writer) == 0 ? 0 : 1;
      }
    EOS
    system ENV.cc, "-std=c11", "smoke.c", "-I#{include}", "-L#{lib}", "-lmaelys_cli", "-o", "smoke"
    system "./smoke"
    (testpath/"schema.json").write "{\"type\":\"object\"}\n"
    assert_match "extern const char smoke_schema[];",
                 shell_output("#{bin}/maelys-cli-embed --header smoke_schema=#{testpath}/schema.json")
  end
end

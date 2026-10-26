# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag. Installs the framework
# to build a Maelys command-line product: libraries, headers, pkg-config
# files, the schema embedding tool, the reference generator, agent texts
# and templates. The `maelys` command itself is the `maelys` formula.
class LibmaelysCli < Formula
  desc "Framework and tools to build a Maelys command-line product"
  homepage "https://github.com/maelys-dev/maelys-cli"
  url "https://github.com/maelys-dev/maelys-cli/archive/refs/tags/v0.14.0.tar.gz"
  sha256 "ba17900043001d4e61d2f8f611bed91d1021b1524164379f5278c6603a81b832"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-cli/releases/download/v0.14.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "091b02d45af24b9cb88e93230864cc581232356f959bc4b8a65d2dab69f6c032"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "bf2d93bf34e105c4a5f2732d94c50be8019ddc02b6029866dd4b56c93d50dcea"
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

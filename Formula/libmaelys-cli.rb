# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag. Installs the framework
# to build a Maelys command-line product: libraries, headers, pkg-config
# files, the schema embedding tool, the reference generator, agent texts
# and templates. The `maelys` command itself is the `maelys` formula.
class LibmaelysCli < Formula
  desc "Framework and tools to build a Maelys command-line product"
  homepage "https://github.com/maelys-dev/maelys-cli"
  url "https://github.com/maelys-dev/maelys-cli/archive/refs/tags/v0.15.0.tar.gz"
  sha256 "1bacc2c68bb881647dbddb60fc02cddac36d38914486822f87760fb897123983"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-cli/releases/download/v0.15.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "6b10b20f139bf16ba2adb1f3c81c6a7c83e02b5bf5fe133b0cef20bee2ecde79"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c8f94b54f554eebc2670c7b15c502bae05ed17979f3b4f820fd7a2dda09e9f42"
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

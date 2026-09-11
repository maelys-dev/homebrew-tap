# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysJson < Formula
  desc "Bounded JSON reader and canonical writer for C, shared by the Maelys tools"
  homepage "https://github.com/maelys-dev/maelys-json"
  url "https://github.com/maelys-dev/maelys-json/archive/refs/tags/v0.1.6.tar.gz"
  sha256 "2cb2cc50ea1be13e98b8f8e62e4736341e7bfec6ee62d731762dad71ff4be2a6"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-json/releases/download/v0.1.6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c8e4a2dd64731c7c72512442d4d2d368a0b5a3212b296cb97f64d0e492d6b142"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "8e2b70c8870e6df0dae7540acefbfbc086cc7c2c18f088e3816de0097b5f7650"
  end

  def install
    system "make", "install", "PREFIX=#{prefix}", "CC=#{ENV.cc}"
  end

  test do
    (testpath/"smoke.c").write <<~EOS
      #include <maelys/json.h>
      #include <string.h>
      int main(void) {
        maelys_json_document_t *document = 0;
        maelys_json_error_t error;
        const char text[] = "{\\"ok\\":true}";
        if (maelys_json_document_parse(text, strlen(text), MAELYS_JSON_PROFILE_RFC8259,
                                       0, &document, &error) != MAELYS_JSON_OK) return 1;
        maelys_json_document_release(document);
        return 0;
      }
    EOS
    system ENV.cc, "-std=c11", "smoke.c", "-I#{include}", "-L#{lib}", "-lmaelys-json", "-o", "smoke"
    system "./smoke"
    assert_match "maelys-json", shell_output("pkg-config --list-all --with-path=#{lib}/pkgconfig")
  end
end

# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysJson < Formula
  desc "Bounded JSON reader and canonical writer for C, shared by the Maelys tools"
  homepage "https://github.com/maelys-dev/maelys-json"
  url "https://github.com/maelys-dev/maelys-json/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "cc725703b78c22859f0b39314fe1e819bfc12186bee1df8a0ba5e8f9fc78b801"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-json/releases/download/v0.4.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c7794f51433525e807c37e21f0befa2f0cb99017e5f27492eb89be7b017ec417"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "eebce2a49ac5afd05f12b7be857120b3b2eba4fd3ba8dd03054ec6d955aa2896"
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

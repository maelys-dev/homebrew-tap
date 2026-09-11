# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysJson < Formula
  desc "Bounded JSON reader and canonical writer for C, shared by the Maelys tools"
  homepage "https://github.com/maelys-dev/maelys-json"
  url "https://github.com/maelys-dev/maelys-json/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "c0fba9f6159b75861e380e4d2937e02cd1642fa4469f87ee849f1f55397765ac"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-json/releases/download/v0.2.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "e853330366207e6e333a01e91f1b0337b1c47db5d9ccb3807394fc87c20b2ace"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "2969d536ece917967f82143872a45b46739eda8808ede74dbf20d9efbd74947f"
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

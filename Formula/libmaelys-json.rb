# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysJson < Formula
  desc "Bounded JSON reader and canonical writer for C, shared by the Maelys tools"
  homepage "https://github.com/maelys-dev/maelys-json"
  url "https://github.com/maelys-dev/maelys-json/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "f6836a95a3bd35e0696e5c7bd6999a4d29540559efa1fb2ad149f801ae4d4fe3"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-json/releases/download/v0.3.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "3a8c201f5bf210494c65d919a8019ddf27160c84a08629d1cf39e3e368448d7a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "477dd7c8a8aba9902333179103fd31ac71e7538aea95c8a31eb0c6c9458d34dc"
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

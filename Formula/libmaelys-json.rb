# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysJson < Formula
  desc "Bounded JSON reader and canonical writer for C, shared by the Maelys tools"
  homepage "https://github.com/maelys-dev/maelys-json"
  url "https://github.com/maelys-dev/maelys-json/archive/refs/tags/v0.1.5.tar.gz"
  sha256 "83efc6f5ca918140f1a86c2786a4a747d1af0815d32f351a74f141a0acc9b251"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-json/releases/download/v0.1.5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "268ad484b888659271cc280da1cbeb28226e4ab136f3a8e2c0aa50f3dc632935"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "da0a90054a5f1251110118cfd2adcb2420fa08b87a5561ec1989a2cff8d378d6"
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

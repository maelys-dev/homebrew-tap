# typed: strict
# frozen_string_literal: true

# SPDX-License-Identifier: MPL-2.0

# Bounded JSON-RPC documents and request correlation on maelys-json.
class LibmaelysJsonrpc < Formula
  desc "Bounded JSON-RPC 2.0 documents and request correlation for C11"
  homepage "https://github.com/maelys-dev/maelys-jsonrpc"
  url "https://github.com/maelys-dev/maelys-jsonrpc/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "25f4734b8d4dd3fed04c1bbe8e708fc0a6f52d28749a24c353b0c2845f794221"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-jsonrpc/releases/download/v0.1.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "1768e27c4e44179a707a90a62fe903efee50539fe3eb7be1fd624a524ca2118f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d8b94cb097e7b77718acd888ac9a3c898df07f6bd331f945fc63815bbca6614e"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :test
  depends_on "maelys-dev/tap/libmaelys-json"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args,
           "-DMAELYS_JSONRPC_BUILD_TESTS=OFF", "-DMAELYS_JSONRPC_WERROR=ON",
           "-DMAELYS_JSON_DIR=#{formula_opt_prefix("libmaelys-json")}",
           "-DCMAKE_PREFIX_PATH=#{formula_opt_prefix("libmaelys-json")}"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"smoke.c").write <<~EOS
      #include <maelys/jsonrpc.h>
      int main(void) {
        maelys_json_document_t *doc = 0;
        maelys_jsonrpc_message_t message;
        const char text[] = "{\\"jsonrpc\\":\\"2.0\\",\\"method\\":\\"probe\\"}";
        if (maelys_jsonrpc_parse(text, sizeof text - 1, 0, &doc, 0)) return 1;
        int bad = maelys_jsonrpc_classify(doc, 0, &message) ||
                  message.kind != MAELYS_JSONRPC_NOTIFICATION;
        maelys_json_document_release(doc);
        return bad;
      }
    EOS
    system ENV.cc, "-std=c11", "smoke.c", "-I#{include}",
           "-I#{formula_opt_include("libmaelys-json")}", "-L#{lib}", "-lmaelys-jsonrpc",
           "-L#{formula_opt_lib("libmaelys-json")}", "-lmaelys-json", "-o", "smoke"
    system "./smoke"
    requires = shell_output("pkg-config --print-requires --with-path=#{lib}/pkgconfig maelys-jsonrpc")
    assert_match "maelys-json", requires
  end
end

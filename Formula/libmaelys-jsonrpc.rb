# typed: strict
# frozen_string_literal: true

# SPDX-License-Identifier: MPL-2.0

# Bounded JSON-RPC documents and request correlation on maelys-json.
class LibmaelysJsonrpc < Formula
  desc "Bounded JSON-RPC 2.0 documents and request correlation for C11"
  homepage "https://github.com/maelys-dev/maelys-jsonrpc"
  url "https://github.com/maelys-dev/maelys-jsonrpc/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "55ca02f6389d76f70383f86c0a1490d3e1c43c4f63805f304e42180bd15b0f65"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-jsonrpc/releases/download/v0.2.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "07c57ee78b6f789ed0af0fa9d96993263200e4f5e73f5f919851dea918fb5c32"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "4a27f7722f7ad1cc031562a5a15e3b10a725d9b68ec1247804754e209ebf4819"
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

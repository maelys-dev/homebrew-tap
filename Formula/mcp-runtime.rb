class McpRuntime < Formula
  desc "Native, policy-enforced MCP host for polyglot developer tools"
  homepage "https://github.com/maelys-dev/mcp-runtime"
  url "https://github.com/maelys-dev/mcp-runtime/archive/refs/tags/v0.26.0.tar.gz"
  sha256 "1da184c9b3280cd22a0cf67e03b77f4cbd42e2f548dece317b9a25482ab46d0e"
  license "MIT"

  depends_on "pkg-config" => :build
  depends_on "jansson"
  depends_on "uriparser"

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_match "Usage: maelys-mcp", shell_output("#{bin}/maelys-mcp --help")
    assert_path_exists lib/"libmaelys_mcp.a"
    assert_path_exists include/"maelys/mcp.h"
  end
end

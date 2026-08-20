class McpRuntime < Formula
  desc "Native, policy-enforced MCP host for polyglot developer tools"
  homepage "https://github.com/maelys-dev/mcp-runtime"
  url "https://github.com/maelys-dev/mcp-runtime/archive/refs/tags/v0.15.0.tar.gz"
  sha256 "ad0bc4049828bf8df0c86ff1f668f73d8aa63c29ef8587f43a0007ac24dcb7a5"
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

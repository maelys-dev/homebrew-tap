class McpRuntime < Formula
  desc "Native, policy-enforced MCP host for polyglot developer tools"
  homepage "https://github.com/maelys-dev/mcp-runtime"
  url "https://github.com/maelys-dev/mcp-runtime/archive/refs/tags/v0.18.0.tar.gz"
  sha256 "e518a065d9ffbd9b7bb58bf5516dc7589c7d763feb6bbad63202f9708bc3cb7a"
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

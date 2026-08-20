class McpRuntime < Formula
  desc "Native, policy-enforced MCP host for polyglot developer tools"
  homepage "https://github.com/maelys-dev/mcp-runtime"
  url "https://github.com/maelys-dev/mcp-runtime/archive/refs/tags/v0.14.0.tar.gz"
  sha256 "5136bcc6818ac3e53478e3d9bd6bea8644c8418198cf2a5e7eb513b7421a3428"
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

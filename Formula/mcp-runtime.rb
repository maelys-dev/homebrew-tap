class McpRuntime < Formula
  desc "Native, policy-enforced MCP host for polyglot developer tools"
  homepage "https://github.com/maelys-dev/mcp-runtime"
  url "https://github.com/maelys-dev/mcp-runtime/archive/refs/tags/v0.12.1.tar.gz"
  sha256 "47a07a6a3e672d346de45cee16f605470f2acf7a4774f55a50b3834038e5668e"
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

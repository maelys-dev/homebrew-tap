class MaelysMcp < Formula
  desc "Native, policy-enforced MCP host for polyglot developer tools"
  homepage "https://github.com/maelys-dev/maelys-mcp"
  url "https://github.com/maelys-dev/maelys-mcp/archive/refs/tags/v1.1.1.tar.gz"
  sha256 "f7f3bceef5890f04d6696166b8395004ab3a691859427c4ff782a02b46ac222e"
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

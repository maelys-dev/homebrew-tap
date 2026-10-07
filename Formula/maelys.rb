# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag. Installs the `maelys`
# command only; the framework to build a product CLI is `libmaelys-cli`.
class Maelys < Formula
  desc "Command that runs every installed Maelys tool under one name"
  homepage "https://github.com/maelys-dev/maelys-cli"
  url "https://github.com/maelys-dev/maelys-cli/archive/refs/tags/v0.5.36.tar.gz"
  sha256 "4d0e1dda4406eb7c9098c97c9c22a42239268e13be64cde3a658e9985ff46bbe"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-cli/releases/download/v0.5.36"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "0ef67565021292bc8eb20eafd7f44e6e4b57ef5360393a4dfd70af496596d89e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d92b577655ffb628e1536ea8e8a0259389936dc3f4a820deda59458fe93af798"
  end

  depends_on "libmaelys-json" => :build

  def install
    json = Formula["libmaelys-json"]
    system "make", "install-dispatcher", "PREFIX=#{prefix}", "CC=#{ENV.cc}",
           "MAELYS_JSON_CFLAGS=-I#{json.opt_include}",
           "MAELYS_JSON_LIB=#{json.opt_lib}/libmaelys-json.a",
           "MAELYS_JSON_LIBS=#{json.opt_lib}/libmaelys-json.a"
  end

  test do
    assert_equal "maelys #{version}", shell_output("#{bin}/maelys version").strip
    output = shell_output("#{bin}/maelys commands list --format json --compact --non-interactive")
    assert_match '"contract":"agent-cli/v2"', output
  end
end

# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag. Installs the `maelys`
# command only; the framework to build a product CLI is `libmaelys-cli`.
class Maelys < Formula
  desc "Command that runs every installed Maelys tool under one name"
  homepage "https://github.com/maelys-dev/maelys-cli"
  url "https://github.com/maelys-dev/maelys-cli/archive/refs/tags/v0.12.2.tar.gz"
  sha256 "bcf6be28f3b7e9aa21be4184f2e53e2a81ab2bd7262125498aff5ec274141745"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-cli/releases/download/v0.12.2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "b842e84aa5dac4825e52b24c46eee4385b530097014fd848e731680f765abfd1"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b2891980c6fa61d8b9a892957eaca3725311f81c061925254202728ffd938e4c"
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

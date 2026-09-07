# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag. Installs the `maelys`
# command only; the framework to build a product CLI is `libmaelys-cli`.
class Maelys < Formula
  desc "Command that runs every installed Maelys tool under one name"
  homepage "https://github.com/maelys-dev/maelys-cli"
  url "https://github.com/maelys-dev/maelys-cli/archive/refs/tags/v0.5.20.tar.gz"
  sha256 "9846661b9b5d4d72799ab495da51b3678146c83e4ee1217dda8dc370df48cc49"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-cli/releases/download/v0.5.20"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "e9d74ee287b4e91ad26bc9dfc463bbf148ff18851a579bd210d5d3e6b781ccb1"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "fff8ccee944358f5649e863df4335d56e1615bfad3e6717d62984c97e8a4c830"
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

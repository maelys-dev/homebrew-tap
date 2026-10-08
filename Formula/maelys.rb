# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag. Installs the `maelys`
# command only; the framework to build a product CLI is `libmaelys-cli`.
class Maelys < Formula
  desc "Command that runs every installed Maelys tool under one name"
  homepage "https://github.com/maelys-dev/maelys-cli"
  url "https://github.com/maelys-dev/maelys-cli/archive/refs/tags/v0.6.4.tar.gz"
  sha256 "5c1e229ddb773ed27786250bcafca2543b141faa6fb0fd6de459e9facd87c608"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-cli/releases/download/v0.6.4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "57a3faeb6443c3e0aed404347eceb9b9779fa92806ab87276cd6aacad1228dde"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d3a588ac80a171853d90c3961bb22e9bc5f7a7e679950363438bf96dfb6c319b"
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

# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag. Installs the `maelys`
# command only; the framework to build a product CLI is `libmaelys-cli`.
class Maelys < Formula
  desc "Command that runs every installed Maelys tool under one name"
  homepage "https://github.com/maelys-dev/maelys-cli"
  url "https://github.com/maelys-dev/maelys-cli/archive/refs/tags/v0.5.9.tar.gz"
  sha256 "7858122419d9cffc72d0180cdd724b4b272d9c854b91ac724e821c6447105a8a"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-cli/releases/download/v0.5.9"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "80cf3b2144729fe0c2f42f5032aa60dea0fbb69eb5155a66d698ce4608a97a76"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "be47ae35b4cbbfc6f26c6c622d6cc38ce4dd5ee023eecf6ed37791efa89482e6"
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

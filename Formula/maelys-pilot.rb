# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.10, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.10.tar.gz and 64d26804693c4c39fda01d1e00908c894494cb1501d90b29aa20695883c63ab4 become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.10.tar.gz"
  sha256 "64d26804693c4c39fda01d1e00908c894494cb1501d90b29aa20695883c63ab4"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.10"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "145e3b1805364e47bdef42d1b12a0819f2bc5e82b98ccd86d9408f23ae43443b"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "2372243ab69b5695195de4638d42b6c24f951dac62583e4814d83ef2c63a414a"
  end

  def install
    system "make", "CC=#{ENV.cc}"
    bin.install "build/maelys-pilot"
  end

  # Run on the bottle a user pours, by the socle's tap workflow: what is
  # asserted is what an installed copy answers, not what the build left.
  test do
    assert_equal "maelys-pilot #{version}", shell_output("#{bin}/maelys-pilot --version").strip
    assert_equal "hello, brew", shell_output("#{bin}/maelys-pilot greet brew").strip
    shell_output("#{bin}/maelys-pilot greet", 2)
  end
end

# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.1, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.1.tar.gz and 5795de0b90f3399c7dd651b429ddc48474a5655ec225df7986f28c6822dfc8a5 become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.1.tar.gz"
  sha256 "5795de0b90f3399c7dd651b429ddc48474a5655ec225df7986f28c6822dfc8a5"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "05df636a2e9ecf860a47b120306e480948b6c6c3e9e4418fddc9d8c434b13950"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "48717a2878ad7f9199bedf7794445ab60690bd7ca52d4a48a10c5eb11be7a778"
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

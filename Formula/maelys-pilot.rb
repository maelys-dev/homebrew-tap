# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.11, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.11.tar.gz and 6217d8b63416ab71cd1c9737912537a65ebae8ae5c401870146452d81d829b22 become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.11.tar.gz"
  sha256 "6217d8b63416ab71cd1c9737912537a65ebae8ae5c401870146452d81d829b22"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.11"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "e36365eca250e6932a0d4abe7d22262d2ef95cd48def52c3be228ef2f6a0ab75"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "bca1af938059537945bf9323079ae91363fe129ba923491a26df97d7b9e35e49"
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

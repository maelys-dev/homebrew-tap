# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.4, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.4.tar.gz and 8e36dac6787ffa9cf2ca2ac7617638a47ac37952a5be6bc0cc7c3b992fc669c2 become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.4.tar.gz"
  sha256 "8e36dac6787ffa9cf2ca2ac7617638a47ac37952a5be6bc0cc7c3b992fc669c2"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "4e288193a1392045355eb445c99985eeb56ccd47e6e01ef7143f7d747fe9c613"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "770ace9683eafdf6b453454599021d36c49b54b2e66a3477b3929f8ee550ccfa"
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

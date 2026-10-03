# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.3.0, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.3.0.tar.gz and ca830dc7a2c28d9bc76c093a9e851c7eb07831e21ff38590ab3f23ca114862cf become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "ca830dc7a2c28d9bc76c093a9e851c7eb07831e21ff38590ab3f23ca114862cf"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.3.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "12fc3d0274469b1be9d5a0b5f1067c8a27862bd46a46d018f19c0612049e813c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "7157918b0405c701bc5776080ef702840960dabb42d09672b75ab3a732a23ad0"
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

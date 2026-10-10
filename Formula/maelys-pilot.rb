# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.3, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.3.tar.gz and 1eab74ac0d82c785579676f84cbb8d977668128e36eb79c65147a98e68f7d254 become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.3.tar.gz"
  sha256 "1eab74ac0d82c785579676f84cbb8d977668128e36eb79c65147a98e68f7d254"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "f6f20ac6d9ba7c451abbd7d94364b8ae6a61aa2e33f11669211278b5daf52e28"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9c0210d96aaf30e8235a841d749f0159c968e8432c83a476b354a1c2da66a031"
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

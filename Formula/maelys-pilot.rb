# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.13, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.13.tar.gz and 6b337bb036e97e2cbe6879959f781cb862e7d2bafd86453ef2286106994e0e49 become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.13.tar.gz"
  sha256 "6b337bb036e97e2cbe6879959f781cb862e7d2bafd86453ef2286106994e0e49"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.13"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "239be8c21a0c228a1e101a2edd022b7d3e9e8bcc30afae714b90704a98e0c43a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "8e32bd5d89db1848e0c90e743ad855c4c3501ceb63811317f085157ce0442079"
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

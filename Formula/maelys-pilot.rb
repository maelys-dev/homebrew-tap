# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.2, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.2.tar.gz and f0cd8a6b2454ac519bf9e1ef92b35113b7bc22ebfc17dfc36e0f05a40c051b1c become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.2.tar.gz"
  sha256 "f0cd8a6b2454ac519bf9e1ef92b35113b7bc22ebfc17dfc36e0f05a40c051b1c"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "487f0ae5b513001f8a4d2d4ce457723f2184e16512650410dd7c409e3e90e1a1"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c616570fadf403c067df027061e776d6d52c92c89e7a00307b66da331cb55899"
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

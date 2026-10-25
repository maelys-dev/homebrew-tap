# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.14, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.14.tar.gz and eab784d523bdaa20142cc9278e465d039a8e15e2477b2c6f5f1e6c0134a08256 become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.14.tar.gz"
  sha256 "eab784d523bdaa20142cc9278e465d039a8e15e2477b2c6f5f1e6c0134a08256"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.14"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "817bed68b63cbd25e6d56422ac8f220c7381ec0c379d62f9d8c6adf646bf1f5d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c63ec0d69e55b898a89e110dec0926b11d53e3e5687b2d31542b5b3cae565af6"
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

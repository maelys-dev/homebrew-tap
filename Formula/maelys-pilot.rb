# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.16, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.16.tar.gz and 7c0a2046dc25418c5f456d22cb1cb47b01e2a901c339101e96eece92f6bb6397 become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.16.tar.gz"
  sha256 "7c0a2046dc25418c5f456d22cb1cb47b01e2a901c339101e96eece92f6bb6397"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.16"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "563fff6e2746f69cbe232764832a42512874b776eae9a358eff4b27939979e6c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b6f48c674ef9dcd6c5edc18ea3f95eaa4093fc675a77af5e8fbf5eb5d08cebf5"
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

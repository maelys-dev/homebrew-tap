# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.8, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.8.tar.gz and 48fb52bf29cefb3d1db5b2ab641cb01df39aebd848ade88f496c42e49375059f become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.8.tar.gz"
  sha256 "48fb52bf29cefb3d1db5b2ab641cb01df39aebd848ade88f496c42e49375059f"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.8"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d6472da634e1bd94daa4f65c1cb275b7b83b18fe367114e3b139c0d693dd197c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b15f4a100733c5fdede29c588193e22a7c90e1e9eec0cb916b5efae9fee2af69"
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

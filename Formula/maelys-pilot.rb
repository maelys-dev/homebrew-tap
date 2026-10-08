# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.0, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.0.tar.gz and 0910f9815d8f376dfc1d5fc02940164d6221d6b90451e141328f03c64f50b7c8 become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "0910f9815d8f376dfc1d5fc02940164d6221d6b90451e141328f03c64f50b7c8"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "9d00ec2a631df06d7ca0e787780fa95ae3cab48e089c2a7b3c823da3f4ca4064"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5e7707c3b0c2472745e41f869238d4be37845575eb3310ec2b75151b0e61bb42"
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

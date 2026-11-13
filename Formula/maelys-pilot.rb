# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.17, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.17.tar.gz and 472cd027924d1166af383cdcaf187088857b54b1e42136b36390411507cfddb1 become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.17.tar.gz"
  sha256 "472cd027924d1166af383cdcaf187088857b54b1e42136b36390411507cfddb1"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.17"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "a35c6982e7912726925865352285ee3e8d9e351b23c0ace2656cca6c1d9d0fa4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ce3379ac2009aa0db4c0870fcb004ac72eb3ae13338aaecaea38c5761bdfb07c"
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

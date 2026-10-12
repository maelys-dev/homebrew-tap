# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.7, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.7.tar.gz and 87152b6df10d62636c3263df1e7c54cbedfc399c42de604dc2bcc11112d6177f become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.7.tar.gz"
  sha256 "87152b6df10d62636c3263df1e7c54cbedfc399c42de604dc2bcc11112d6177f"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.7"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "4bd30e6c41993a1a0140084b7360fee612c937cfe4d306941f005334d1845155"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "6fa6221c42822fb6010dbc0f1026edc2133b8174d8e631be94c0605bad48c803"
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

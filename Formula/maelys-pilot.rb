# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.15, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.15.tar.gz and 199d8b9356308364149186b94181cb255016704d4973560e9f6a3e2d1a89fb80 become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.15.tar.gz"
  sha256 "199d8b9356308364149186b94181cb255016704d4973560e9f6a3e2d1a89fb80"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.15"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "fb3880a823c6bd8671c66e2a1856aadf79764325cb961f5411aee177f54a74e6"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "6ea8f3e4645ede0372b7a7bc1d3b3f2505d1596f194d8ae56cdc58a89d5f9987"
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

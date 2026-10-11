# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.6, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.6.tar.gz and 2919d36857317089ce6e9b69e8658c6e733c3a42474b9f9702dabda488fb694d become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.6.tar.gz"
  sha256 "2919d36857317089ce6e9b69e8658c6e733c3a42474b9f9702dabda488fb694d"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "70965abe6da8a590c49fdbc0dd630240eb0cd3134a441800444c16319df87321"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "7cfd68a85e1db9a3420d30106301d4201c640b47ae8860e3d8f219aff11f25ae"
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

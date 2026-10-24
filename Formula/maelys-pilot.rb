# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.12, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.12.tar.gz and ff497c453de6b825b3ae13675999db87a12171b8f579002bb466b0705a06f557 become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.12.tar.gz"
  sha256 "ff497c453de6b825b3ae13675999db87a12171b8f579002bb466b0705a06f557"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.12"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d00763baddc6df513420a604ce8431b66704b55d6bfa5559fb7683543830c516"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5a66e22dc4adce83bc63a0811831baaa77177c28fb74a8de7de2ec47c0316f6a"
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

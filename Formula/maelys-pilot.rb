# typed: strict
# frozen_string_literal: true

# The pilot's formula, rendered by the socle's tap workflow from this
# template: 0.4.5, https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.5.tar.gz and 8fb0ce29e4c7cd514d89affb59c315a1307d863a79a6d7b06c93b8b221102028 become the source archive of one
# tag. It exists so that the socle's Homebrew path -- render, bottle, pour,
# test, publish -- runs on the pilot before it runs on a product.
class MaelysPilot < Formula
  desc "Smallest product the Maelys socle can release, kept to try its writes"
  homepage "https://github.com/maelys-dev/maelys-pilot"
  url "https://github.com/maelys-dev/maelys-pilot/archive/refs/tags/v0.4.5.tar.gz"
  sha256 "8fb0ce29e4c7cd514d89affb59c315a1307d863a79a6d7b06c93b8b221102028"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-pilot/releases/download/v0.4.5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "f00cfaccc192c0c4f641b3c1d0074c3fbc28180d5abc28c8ceb11044bee177cc"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "eeead07c12f745aef91b01b932bae6e1190fa1b402d4fdc12e64a2b9599dd21f"
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

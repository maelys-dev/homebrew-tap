# typed: strict
# frozen_string_literal: true

# Rendered from packaging/homebrew/maelys-sandbox-policy.rb.in for one tag by
# scripts/render-homebrew-formula.sh: the source archive, its digest and the
# pinned maelys-cli below are copied from that tag.
class MaelysSandboxPolicy < Formula
  desc "Compile portable sandbox decisions into canonical MIR and host plans"
  homepage "https://policy.maelys.dev"
  url "https://github.com/maelys-dev/maelys-sandbox-policy/archive/refs/tags/v0.9.0.tar.gz"
  sha256 "58436ab301688e058086d3579e29f08ab709f52effeb614ac87210d1aab2d023"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-sandbox-policy/releases/download/v0.9.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "3f609e201c022070a1a18d662c6b1c8c5002701a7d5237f96d52201f7ba5b918"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ed898483efaed3c389478a0da107b05be217bd96efea69b51866f9a8264dbd85"
  end

  resource "maelys-cli" do
    url "https://github.com/maelys-dev/maelys-cli.git",
        tag:      "v0.5.30",
        revision: "da330c75c21daf8a03e42227012e20a4f9592549"
  end

  def install
    # The Makefile verifies the maelys-cli checkout against
    # dependencies/maelys-cli.pin before it links maelys-policy on it.
    cli_dir = buildpath/"vendor/maelys-cli"
    resource("maelys-cli").stage cli_dir
    system "make", "install", "PREFIX=#{prefix}", "MAELYS_CLI_DIR=#{cli_dir}"
  end

  test do
    (testpath/"policy.json").write <<~JSON
      {"formatVersion":3,"filesystem":{"default":"deny","rules":[]},"network":{"mode":"none"},"root":{"mode":"read-only"},"process":{"treeConfinement":"disabled"}}
    JSON
    system bin/"maelys-policy", "compile", "policy.json", "--output", "policy.mir", "--apply"
    system bin/"maelys-policy", "validate", "policy.mir"
    assert_equal version.to_s, shell_output("#{bin}/maelys-policy version --field version").strip
  end
end

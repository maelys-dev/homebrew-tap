# typed: strict
# frozen_string_literal: true

# Rendered from packaging/homebrew/maelys-sandbox-policy.rb.in for one tag by
# scripts/render-homebrew-formula.sh: the source archive, its digest and the
# pinned maelys-cli below are copied from that tag.
class MaelysSandboxPolicy < Formula
  desc "Compile portable sandbox decisions into canonical MIR and host plans"
  homepage "https://policy.maelys.dev"
  url "https://github.com/maelys-dev/maelys-sandbox-policy/archive/refs/tags/v0.11.0.tar.gz"
  sha256 "b565b7cb49049f5bba9fefdb8951f2893cfbb47f476517bc6a6db737dfd2bd71"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-sandbox-policy/releases/download/v0.11.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "212841787b2941f791099a97c2a932c5c01d41f941118d05c4c8edb471bcf9c8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "96f43b7300f3f8b3186202b2113247b82f3db787f0a82806032b7147b107d7c8"
  end

  resource "maelys-cli" do
    url "https://github.com/maelys-dev/maelys-cli.git",
        tag:      "v0.6.2",
        revision: "91145f61c2484e7dfa1b2877b8850bad105e56e6"
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

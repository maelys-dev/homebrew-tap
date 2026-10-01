# typed: strict
# frozen_string_literal: true

# Rendered from packaging/homebrew/maelys-sandbox-policy.rb.in for one tag by
# scripts/render-homebrew-formula.sh: the source archive, its digest and the
# pinned maelys-cli below are copied from that tag.
class MaelysSandboxPolicy < Formula
  desc "Compile portable sandbox decisions into canonical MIR and host plans"
  homepage "https://policy.maelys.dev"
  url "https://github.com/maelys-dev/maelys-sandbox-policy/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "145a487cfb98b17d3449dba8e5631c364df8e244ef3365c9edfc3fb377bc534e"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-sandbox-policy/releases/download/v0.7.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c16c03544bd3b8adc5f2228ef5761d429918d61ed60a0f5693a962ae36cbf20a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "78841ab39aed109d84fabd84410aca484a5058d5a3842b0da8de88405ce2dcdb"
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

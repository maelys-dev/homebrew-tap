class MaelysSandboxPolicy < Formula
  desc "Compile portable sandbox decisions into canonical MIR and host plans"
  homepage "https://policy.maelys.dev"
  url "https://github.com/maelys-dev/maelys-sandbox-policy/archive/refs/tags/v0.4.1.tar.gz"
  sha256 "9fd53506a7fbf034fd9555d6623765d873b2029a1a0b120ebcbc2b3e480ba20d"
  license "MPL-2.0"

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"policy.json").write <<~JSON
      {"formatVersion":2,"filesystem":{"default":"deny","rules":[]},"network":{"mode":"none"},"process":{"treeConfinement":"disabled"}}
    JSON
    system bin/"maelys-policy", "compile", "policy.json", "-o", "policy.mir"
    system bin/"maelys-policy", "validate", "policy.mir"
    assert_equal version.to_s, shell_output("#{bin}/maelys-policy --version").strip
  end
end

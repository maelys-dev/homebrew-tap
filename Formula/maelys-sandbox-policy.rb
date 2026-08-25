class MaelysSandboxPolicy < Formula
  desc "Compile portable sandbox decisions into canonical MIR and host plans"
  homepage "https://policy.maelys.dev"
  url "https://github.com/maelys-dev/maelys-sandbox-policy/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "3b7ab1a3f7b476e7ce0a6959f506c0fac52c5ccc18e8360581032db88d051bf0"
  license "MIT"

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

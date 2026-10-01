# typed: strict
# frozen_string_literal: true

# The renderer copies every dependency pin from this tag's source archive.
class MaelysDatalog < Formula
  desc "Command-line policy validation, solving and explanations for Maelys Datalog"
  homepage "https://github.com/maelys-dev/maelys-datalog-cli"
  url "https://github.com/maelys-dev/maelys-datalog-cli/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "4ecd688229f8e210f8e7aaab0b5e82455eae4bc5dc5620d332c20c3643e26261"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-datalog-cli/releases/download/v0.1.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "7ea07510d3d4695ed6fc9fbbb036a76e19a5807d3b9405bdb1e588a055f5dabc"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f0e2b1c99aeda24331b7162bb6d3ab4d642c261399dfeac087caca9ba21a3cf7"
  end

  depends_on "cmake" => :build
  depends_on "git" => :build

  resource "maelys-datalog" do
    url "https://github.com/maelys-dev/maelys-datalog.git",
        tag: "v0.17.0", revision: "0f363e31beb2dc318f069e41e81000b688d330aa"
  end

  resource "maelys-cli" do
    url "https://github.com/maelys-dev/maelys-cli.git",
        tag: "v0.5.30", revision: "da330c75c21daf8a03e42227012e20a4f9592549"
  end

  resource "maelys-json" do
    url "https://github.com/maelys-dev/maelys-json.git",
        tag: "v0.2.0", revision: "77849ce6aabeb7e06d8adeca7b60037b1596e304"
  end

  def install
    ENV.deparallelize
    dependencies = buildpath/"vendor"
    resource("maelys-datalog").stage dependencies/"maelys-datalog"
    resource("maelys-cli").stage dependencies/"maelys-cli"
    resource("maelys-json").stage dependencies/"maelys-json"
    system "make", "install", "PREFIX=#{prefix}",
           "MAELYS_DEPENDENCIES_DIR=#{dependencies}"
  end

  test do
    assert_equal "maelys-datalog 0.1.1",
                 shell_output("#{bin}/maelys-datalog version").strip
    (testpath/"domain.json").write <<~JSON
      {"format":"maelys-datalog-domain-v1","name":"brew_smoke","predicates":[{"name":"input","arity":1,"role":"edb"},{"name":"allow","arity":1,"role":"idb","query":true}],"atoms":[]}
    JSON
    (testpath/"policy.dl").write "allow(X) :- input(X).\n"
    (testpath/"facts.dl").write "input(\"ok\").\n"
    command = "#{bin}/maelys-datalog solve --domain #{testpath}/domain.json " \
              "--facts #{testpath}/facts.dl #{testpath}/policy.dl"
    result = shell_output(command)
    assert_match 'allow("ok").', result
  end
end

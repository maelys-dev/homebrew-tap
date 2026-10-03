# typed: strict
# frozen_string_literal: true

# The renderer copies every dependency pin from this tag's source archive.
class MaelysDatalog < Formula
  desc "Command-line policy validation, solving and explanations for Maelys Datalog"
  homepage "https://github.com/maelys-dev/maelys-datalog-cli"
  url "https://github.com/maelys-dev/maelys-datalog-cli/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "0a979c4a7a0de07632011163346e4a4434b4b22c8ce43d47941510def32b0dda"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-datalog-cli/releases/download/v0.2.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "e2a4732ba7de4ae2c69491418c278f0eb23b56ef33fa57eacc338b78359085f3"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0db914a07b600b87f3b59b112208f8cc62f0b4ba77e527d5d384f2fa3828feab"
  end

  depends_on "cmake" => :build
  depends_on "git" => :build

  resource "maelys-datalog" do
    url "https://github.com/maelys-dev/maelys-datalog.git",
        tag: "v0.20.0", revision: "e418dfd2bd5473eceb40fc4323bee086cb4fe3bd"
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
    assert_equal "maelys-datalog 0.2.0",
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
    queries = shell_output("#{bin}/maelys-datalog queries --domain #{testpath}/domain.json #{testpath}/policy.dl")
    assert_match "allow/1", queries
  end
end

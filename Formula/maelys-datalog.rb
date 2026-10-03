# typed: strict
# frozen_string_literal: true

# The renderer copies every dependency pin from this tag's source archive.
class MaelysDatalog < Formula
  desc "Command-line policy validation, solving and explanations for Maelys Datalog"
  homepage "https://github.com/maelys-dev/maelys-datalog-cli"
  url "https://github.com/maelys-dev/maelys-datalog-cli/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "d0ab82890436db98c2c0494ce27927ce0452963cc694e7bfb00262bb575101ab"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-datalog-cli/releases/download/v0.3.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "554cc0370d24b1ea5324187ea9133718ffba6e0ccd3e9bb8717e371c8a25cd14"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9bb81caaa973c4e4907fc7d1d0bf503f7933ee6cdb063451d8045efae1f18552"
  end

  depends_on "cmake" => :build
  depends_on "git" => :build

  resource "maelys-datalog" do
    url "https://github.com/maelys-dev/maelys-datalog.git",
        tag: "v0.21.0", revision: "9630f591637c7046ec73996458e1ba282194e32c"
  end

  resource "maelys-cli" do
    url "https://github.com/maelys-dev/maelys-cli.git",
        tag: "v0.5.33", revision: "fb22dda2c3db9ce9606f1610fd5c83465566874c"
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
    assert_equal "maelys-datalog 0.3.1",
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

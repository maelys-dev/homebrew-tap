# typed: strict
# frozen_string_literal: true

# The renderer copies every dependency pin from this tag's source archive.
class MaelysDatalog < Formula
  desc "Command-line policy validation, solving and explanations for Maelys Datalog"
  homepage "https://github.com/maelys-dev/maelys-datalog-cli"
  url "https://github.com/maelys-dev/maelys-datalog-cli/archive/refs/tags/v0.4.1.tar.gz"
  sha256 "0456205d0a260dd9d1c6380b7d99cd82104153d15d64b946b222d2044836f165"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-datalog-cli/releases/download/v0.4.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "3d0302db1ebe6798c9dd07ecdc9d5771375defc174a1b6366aee369cdb0fe1af"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d34491b5b81529b817151241351bb40a2a3efeccd320e830bc5dda6695d200ef"
  end

  depends_on "git" => :build
  depends_on "maelys-dev/tap/libmaelys-datalog" => :build
  depends_on "python@3.14" => :build

  resource "maelys-cli" do
    url "https://github.com/maelys-dev/maelys-cli.git",
        tag: "v0.12.4", revision: "5873f336cf57bd63f5cda862be099139bb773409"
  end

  resource "maelys-json" do
    url "https://github.com/maelys-dev/maelys-json.git",
        tag: "v0.3.0", revision: "d106890b02b3fbfd599ecd22bdeffb600db66123"
  end

  def install
    ENV.deparallelize
    dependencies = buildpath/"vendor"
    resource("maelys-cli").stage dependencies/"maelys-cli"
    resource("maelys-json").stage dependencies/"maelys-json"
    system "make", "install", "PREFIX=#{prefix}",
           "MAELYS_DEPENDENCIES_DIR=#{dependencies}",
           "INSTALLED_SDK_PREFIX=#{formula_opt_prefix("libmaelys-datalog")}"
  end

  test do
    assert_path_exists man1/"maelys-datalog.1"
    assert_equal "maelys-datalog 0.4.1",
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

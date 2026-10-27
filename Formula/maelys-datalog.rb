# typed: strict
# frozen_string_literal: true

# The renderer copies every dependency pin from this tag's source archive.
class MaelysDatalog < Formula
  desc "Command-line policy validation, solving and explanations for Maelys Datalog"
  homepage "https://github.com/maelys-dev/maelys-datalog-cli"
  url "https://github.com/maelys-dev/maelys-datalog-cli/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "68f8ca36eef88b6c598c0e02da6488d670c6044b87d274c9b9bf4176c342c857"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-datalog-cli/releases/download/v0.6.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d021562db6ef8e94829a04b2250ad1a16260062eab8961ae54cdc67dff9e75e2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c024455a5fdad98505c430dc73c563085aad3ebc92c4fd688dfc6d0f6990ef44"
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
    assert_equal "maelys-datalog 0.6.0",
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

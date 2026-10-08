# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysDatalog < Formula
  desc "Bounded Datalog policy engine and public C extension SDK"
  homepage "https://github.com/maelys-dev/maelys-datalog"
  url "https://github.com/maelys-dev/maelys-datalog/archive/refs/tags/v0.22.0.tar.gz"
  sha256 "f7f8c5aab39a49713478afffce377512d6ef77d28824c50b5e72f7a94770ea7f"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-datalog/releases/download/v0.22.0"
    sha256 cellar: :any, arm64_tahoe:   "14888519c26f2ec311b5745821a4c083d1e5646b8b62d3ca0db84809df23af46"
    sha256 cellar: :any, arm64_sequoia: "8f406e862749e0763928b6390f1012e98a18aaa2d656ffead9bed4a3824774aa"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :test

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args,
           "-DCMAKE_BUILD_TYPE=Release", "-DBUILD_TESTING=OFF"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_path_exists include/"maelys/datalog.h"
    assert_path_exists lib/"libmaelys_datalog.a"
    assert_path_exists lib/"pkgconfig/maelys-datalog.pc"
    assert_equal version.to_s,
                 shell_output("pkg-config --with-path=#{lib}/pkgconfig --modversion maelys-datalog").strip
    (testpath/"smoke.c").write <<~EOS
      #include <maelys/datalog.h>
      #include <stddef.h>
      int main(void) {
        size_t bound = 0;
        if (maelys_datalog_limit_get(MAELYS_DATALOG_LIMIT_MAX_FACTS_PER_PRED,
                                    &bound) != MAELYS_DATALOG_STATUS_OK) return 1;
        return bound == 64 ? 0 : 2;
      }
    EOS
    flags = shell_output("pkg-config --with-path=#{lib}/pkgconfig --cflags --libs maelys-datalog").split
    system ENV.cc, "-std=c11", "smoke.c", *flags, "-o", "smoke"
    system "./smoke"
  end
end

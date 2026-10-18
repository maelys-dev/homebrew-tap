# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysDatalog < Formula
  desc "Bounded Datalog policy engine and public C extension SDK"
  homepage "https://github.com/maelys-dev/maelys-datalog"
  url "https://github.com/maelys-dev/maelys-datalog/archive/refs/tags/v0.24.0.tar.gz"
  sha256 "9f526cb302cce07b9899c7a22296fa558093324544935a12cd2bac74e20206d8"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-datalog/releases/download/v0.24.0"
    sha256 cellar: :any, arm64_tahoe:   "31ac217ad21ea82a8835f119a03b4d02b770c7b64e216a880fd0f501368c6b13"
    sha256 cellar: :any, arm64_sequoia: "3b72931442c2fdeb5530592a7b6162e03b83f8077ca2aa0c6956a500a0cab27e"
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

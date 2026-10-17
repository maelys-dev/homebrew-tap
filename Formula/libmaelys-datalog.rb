# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysDatalog < Formula
  desc "Bounded Datalog policy engine and public C extension SDK"
  homepage "https://github.com/maelys-dev/maelys-datalog"
  url "https://github.com/maelys-dev/maelys-datalog/archive/refs/tags/v0.23.1.tar.gz"
  sha256 "5fcb1d42127efb3b9cc3c629815835b27d370cc21bb90510862711983fa37e1d"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-datalog/releases/download/v0.23.1"
    sha256 cellar: :any, arm64_tahoe:   "0001f4ac1903c7ce9c81659af79922e936e88cff195ab3ac23ff0a656356dc06"
    sha256 cellar: :any, arm64_sequoia: "b158048b3368de8278343ffbc71e9cb7535547f2d2b6b2811067b0a614066d82"
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

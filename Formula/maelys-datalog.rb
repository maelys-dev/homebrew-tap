class MaelysDatalog < Formula
  desc "Bounded deterministic Datalog engine for embedded policy decisions"
  homepage "https://github.com/maelys-dev/maelys-datalog"
  url "https://github.com/maelys-dev/maelys-datalog/archive/refs/tags/v0.1.0-alpha.1.tar.gz"
  sha256 "be18f6ef2ce9cf16d90ffb40770bf92cb5d2d00526c72553aaf97689ae55a4c3"
  license "MIT"

  def install
    system "make", "libmaelys_datalog.a"
    lib.install "libmaelys_datalog.a"
    # The public header includes engine headers by repo-relative paths
    # ("src/core/...", "common/..."); install them under include/ preserving
    # that layout so `#include <maelys_datalog.h>` works with a single -I.
    include.install "include/maelys_datalog.h"
    (include/"src/core").install Dir["src/core/*.h"]
    (include/"src/manifest").install Dir["src/manifest/*.h"]
    (include/"common").install Dir["common/*.h"]
  end

  test do
    (testpath/"smoke.c").write <<~EOS
      #include <maelys_datalog.h>
      #include <stdio.h>
      int main(void) { printf("%s\\n", MAELYS_DATALOG_VERSION_STRING); return 0; }
    EOS
    system ENV.cc, "smoke.c", "-I#{include}", "-L#{lib}", "-lmaelys_datalog", "-o", "smoke"
    assert_equal version.to_s, shell_output("./smoke").strip
  end
end

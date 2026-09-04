# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysSys < Formula
  desc "Minimal callback-free POSIX systems foundation for C"
  homepage "https://github.com/maelys-dev/maelys-system"
  url "https://github.com/maelys-dev/maelys-system/archive/refs/tags/v0.5.6.tar.gz"
  sha256 "8276cff648889ef4feba5b4e5f353c414105817a6fa3758872405e5f32b865b0"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-system/releases/download/v0.5.6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "2d5eb4779a5034b639738ea0dcfad7d5f9f04d7873e6457998215b938abb6cfc"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "4a19a850fda2ad8e7adeda7d6c80007b10c497a74b7da27e8b244f1475057ca6"
  end

  # maelys-warden still vendors this library and its headers.
  conflicts_with "maelys-warden", because: "both install libmaelys_sys and the Maelys System headers"

  def install
    system "make", "CC=#{ENV.cc}", "CXX=#{ENV.cxx}", "check"
    system "make", "CC=#{ENV.cc}", "CXX=#{ENV.cxx}", "PREFIX=#{prefix}", "install"
  end

  test do
    (testpath/"smoke.c").write <<~EOS
      #include <maelys/sys.h>
      int main(void) {
        maelys_sys_loop_t *loop = 0;
        if (maelys_sys_loop_create(MAELYS_SYS_LOOP_AUTO, &loop)) return 1;
        return maelys_sys_loop_destroy(&loop);
      }
    EOS
    system ENV.cc, "-std=c11", "-pthread", "smoke.c", "-I#{include}", "-L#{lib}",
           "-lmaelys_sys", "-o", "smoke"
    system "./smoke"
  end
end

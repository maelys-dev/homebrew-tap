# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysSys < Formula
  desc "Minimal callback-free POSIX systems foundation for C"
  homepage "https://github.com/maelys-dev/maelys-system"
  url "https://github.com/maelys-dev/maelys-system/archive/refs/tags/v0.8.1.tar.gz"
  sha256 "dcffe2458b846333640f54a9b31c0afeee1dbd01849914b8c6bb88044d3c88a3"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-system/releases/download/v0.8.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "37679300d3e4232579c952271e76456c37cfc4dfe2c2aeb167018423ad4c4f0b"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c40fe5da186d6d5ac60f385ed4c894110e110187d9f23b32fd6a9bd42924ec59"
  end

  # maelys-warden still vendors this library and its headers.
  conflicts_with "maelys-warden", because: "both install libmaelys_sys and the Maelys System headers"

  def install
    system "make", "CC=#{ENV.cc}", "CXX=#{ENV.cxx}", "WERROR=", "check"
    system "make", "CC=#{ENV.cc}", "CXX=#{ENV.cxx}", "WERROR=", "PREFIX=#{prefix}", "install"
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

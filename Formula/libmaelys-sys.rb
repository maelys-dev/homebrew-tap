# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysSys < Formula
  desc "Minimal callback-free POSIX systems foundation for C"
  homepage "https://github.com/maelys-dev/maelys-system"
  url "https://github.com/maelys-dev/maelys-system/archive/refs/tags/v0.9.1.tar.gz"
  sha256 "258096f09447001756ea96c01c50d6a5b4e70c47dcfee5b8ffa6612765fb643b"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-system/releases/download/v0.9.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "a37ac42a95e03ef42b3494fed088f21eb3b9e010aaed552c24ab6ab1b9f152a2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "cb28bbd17cf16928ef1517d712d65ff9e2a0b59f21e2ea3680c8f129984d9fa5"
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

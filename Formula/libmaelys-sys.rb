# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysSys < Formula
  desc "Minimal callback-free POSIX systems foundation for C"
  homepage "https://github.com/maelys-dev/maelys-system"
  url "https://github.com/maelys-dev/maelys-system/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "d9f0b4d4afb732c29a08be420a093d000a83794b6f9e3ffd3bbf638a68b2e43f"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-system/releases/download/v0.6.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "fa8712795754f9fb030df3dc1f2e1103d6c535ac3f3f896870de739dfc946e00"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "bc30a28a0507ff9634b0b63bdd6578b4676978143d1c3e55011846fc79d502b8"
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

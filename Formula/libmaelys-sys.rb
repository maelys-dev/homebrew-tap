# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysSys < Formula
  desc "Minimal callback-free POSIX systems foundation for C"
  homepage "https://github.com/maelys-dev/maelys-system"
  url "https://github.com/maelys-dev/maelys-system/archive/refs/tags/v0.12.0.tar.gz"
  sha256 "d44d1a1eed84e793930c9846c3a8172fe5d9116235aa36c497d0756b7dc7e0eb"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-system/releases/download/v0.12.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "aca8d846f8fe7bdfab4d1850a5fecc1e20724ab1326ac5e5977093f6a7500a28"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "29a01a39d8341bc9426aad3b586ed33c32ceeb3ab31edffec67227a64e5fbed1"
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

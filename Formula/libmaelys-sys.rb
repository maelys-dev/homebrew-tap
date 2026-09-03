# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysSys < Formula
  desc "Minimal callback-free POSIX systems foundation for C"
  homepage "https://github.com/maelys-dev/maelys-system"
  url "https://github.com/maelys-dev/maelys-system/archive/refs/tags/v0.5.4.tar.gz"
  sha256 "ffbc55a73480ec43a5a0d7a4568508b6a97a40ac0599436d7b80831319eda74d"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-system/releases/download/v0.5.4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "8811b6f4c0276dbea0d73d027d3c58fc0bf3dffd9db412e2d66913a83a1dca7a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "8d33a1d0c1a9691b5480b7a6a23bb09c77073ee2cff5c638df097a33c8966534"
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

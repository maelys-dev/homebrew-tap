# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysSys < Formula
  desc "Minimal callback-free POSIX systems foundation for C"
  homepage "https://github.com/maelys-dev/maelys-system"
  url "https://github.com/maelys-dev/maelys-system/archive/refs/tags/v0.9.0.tar.gz"
  sha256 "854e610effdc9194ff7b9d2a762e06506407f8767e443b2929e747ad110d8523"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-system/releases/download/v0.9.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "b1e071a054528733a02fad0b0222e93a5a2966239f77ac208f35d59b6c38c259"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "549d7fa75c27abbf146e9388ae73c3b8da6480e2224a892956c6bc31bb4abc4b"
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

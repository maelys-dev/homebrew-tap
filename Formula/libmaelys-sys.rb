# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysSys < Formula
  desc "Minimal callback-free POSIX systems foundation for C"
  homepage "https://github.com/maelys-dev/maelys-system"
  url "https://github.com/maelys-dev/maelys-system/archive/refs/tags/v0.5.3.tar.gz"
  sha256 "ac6a322f33ca301c7ef8da3475d49603ec54e753d202e2089a904d46194ff15f"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-system/releases/download/v0.5.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "a815350a035a86012ade5cc4ab338ad2fedd61e4a44346d1508d2230576a9ba6"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "119febfb4d07112410b3e7f4cadeac7be5189891ec7f1f298b4c918b1cbf95d5"
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

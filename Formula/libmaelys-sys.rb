# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysSys < Formula
  desc "Minimal callback-free POSIX systems foundation for C"
  homepage "https://github.com/maelys-dev/maelys-system"
  url "https://github.com/maelys-dev/maelys-system/archive/refs/tags/v0.5.5.tar.gz"
  sha256 "22a3a4c93b36d5788f948573513c881ea3aaff8beea35e071ad51830c669cf85"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-system/releases/download/v0.5.5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "22ceb83ee93a26a8b24cecc78fc5252883836a8b11ff47fce3352484af7f7cb1"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "2eefb21bb55b1f0e6392533f97b1e7d53ccb4e8d69f3768ada200c6fb2a096b0"
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

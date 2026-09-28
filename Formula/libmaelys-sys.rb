# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysSys < Formula
  desc "Minimal callback-free POSIX systems foundation for C"
  homepage "https://github.com/maelys-dev/maelys-system"
  url "https://github.com/maelys-dev/maelys-system/archive/refs/tags/v0.10.0.tar.gz"
  sha256 "fe23bb1be4986dbf7c3d0baa89b87ffcb64ceb2159c42fcc73fac05e22f4e616"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-system/releases/download/v0.10.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "07560c0aff8e26f484fc6bf5937896a256d4d5aa7a26f451f0c65da61c627ef9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "4a279c9d91629a9f968080444cd546d23cbdbf00a0338fad94f185874ea2af75"
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

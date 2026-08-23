class MaelysExecutor < Formula
  desc "Policy-agnostic process execution and sandbox backend library"
  homepage "https://github.com/maelys-dev/maelys-executor"
  url "https://github.com/maelys-dev/maelys-executor/archive/refs/tags/v0.9.0.tar.gz"
  sha256 "1ee450d06c89d7f69a291f8960e4844c19a7c34e4e9672baa688e2d817f4d783"
  license all_of: ["MIT", "Apache-2.0"]

  on_macos do
    depends_on macos: :sequoia
  end

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"smoke.c").write <<~EOS
      #include <maelys/executor.h>
      int main(void) {
        return MAELYS_EXECUTOR_ABI_VERSION > 0u ? 0 : 1;
      }
    EOS
    system ENV.cc, "smoke.c", "-I#{include}", "-L#{lib}",
           "-lmaelys_executor", "-pthread", "-o", "smoke"
    system "./smoke"
  end
end

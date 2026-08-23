class MaelysExecutor < Formula
  desc "Run commands through portable sandbox profiles; includes the C SDK"
  homepage "https://github.com/maelys-dev/maelys-executor"
  url "https://github.com/maelys-dev/maelys-executor/archive/refs/tags/v0.11.0.tar.gz"
  sha256 "90778614037a476da7cda219071988d7331424ce6bf9c138d81327eeea5fa4a6"
  license all_of: ["MIT", "Apache-2.0"]

  on_macos do
    depends_on macos: :sequoia
  end

  resource "maelys-sandbox" do
    url "https://github.com/maelys-dev/maelys-sandbox/archive/refs/tags/v0.2.0.tar.gz"
    sha256 "d5399b88889be8eb6449890cb12c8e9b40d61a63cda12db411c3ab7dd14b13c3"
  end

  def install
    sandbox = buildpath/"vendor/maelys-sandbox"
    resource("maelys-sandbox").stage sandbox
    system "make", "install", "install-cli", "PREFIX=#{prefix}",
           "MAELYS_SANDBOX_DIR=#{sandbox}", "MAELYS_SANDBOX_PINNED_ARCHIVE=1"
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
    assert_equal version.to_s, shell_output("#{bin}/maelys-exec --version").strip
  end
end

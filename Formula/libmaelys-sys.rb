# typed: strict
# frozen_string_literal: true

# Rendered by maelys-release for one released tag.
class LibmaelysSys < Formula
  desc "Minimal callback-free POSIX systems foundation for C"
  homepage "https://github.com/maelys-dev/maelys-system"
  url "https://github.com/maelys-dev/maelys-system/archive/refs/tags/v0.12.3.tar.gz"
  sha256 "6732217f5f0bf1462168bb3ba11fc5b613e2c133667e44747716975bf16c73e5"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-system/releases/download/v0.12.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c75f54fe722fe531f0a49e5739833a56396ce4a9abe7c57f7808555712edc2d8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "6ad85cb67798f6acc63b9a7d30fb44618459b05b099826f63e8a6104de685b26"
  end

  # maelys-warden still vendors this library and its headers.
  conflicts_with "maelys-warden", because: "both install libmaelys_sys and the Maelys System headers"

  def install
    system "make", "CC=#{ENV.cc}", "CXX=#{ENV.cxx}", "WERROR=", "check"
    system "make", "CC=#{ENV.cc}", "CXX=#{ENV.cxx}", "WERROR=", "PREFIX=#{prefix}", "install"
  end

  test do
    (testpath/"smoke.c").write <<~EOS
      #define _POSIX_C_SOURCE 200809L
      #include <maelys/sys.h>
      #include <fcntl.h>
      #include <sys/stat.h>
      #include <unistd.h>
      int main(void) {
        maelys_sys_loop_t *loop = 0;
        if (maelys_sys_loop_create(MAELYS_SYS_LOOP_AUTO, &loop) != MAELYS_SYS_OK) return 1;
        if (maelys_sys_loop_destroy(&loop) != MAELYS_SYS_OK) return 2;
        /* The component added last, through what was installed: a directory
         * watched, one member created, that one change reported. */
        maelys_sys_dirwatch_t *dirwatch = 0;
        maelys_sys_dirwatch_entry_t entry = 0;
        maelys_sys_dirwatch_change_t change;
        size_t count = 0;
        uint64_t deadline = 0;
        unsigned ready = 0;
        if (mkdir("watched", 0700) != 0) return 3;
        if (maelys_sys_dirwatch_create(1, &dirwatch) != MAELYS_SYS_OK) return 4;
        if (maelys_sys_dirwatch_add(dirwatch, "watched", 7, &entry) != MAELYS_SYS_OK) return 5;
        int fd = open("watched/member", O_WRONLY | O_CREAT | O_EXCL, 0600);
        if (fd < 0 || close(fd) != 0) return 6;
        if (maelys_sys_deadline_after(3000, &deadline) != MAELYS_SYS_OK) return 7;
        if (maelys_sys_fd_wait(maelys_sys_dirwatch_fd(dirwatch), MAELYS_SYS_INTEREST_READ,
            deadline, &ready) != MAELYS_SYS_OK) return 8;
        if (maelys_sys_dirwatch_poll(dirwatch, &change, 1, &count) != MAELYS_SYS_OK) return 9;
        if (count != 1 || change.token != 7 || change.entry != entry ||
          change.flags != MAELYS_SYS_DIRWATCH_CHANGED) return 10;
        return maelys_sys_dirwatch_destroy(&dirwatch) == MAELYS_SYS_OK ? 0 : 11;
      }
    EOS
    system ENV.cc, "-std=c11", "-pthread", "smoke.c", "-I#{include}", "-L#{lib}",
           "-lmaelys_sys", "-o", "smoke"
    system "./smoke"
  end
end

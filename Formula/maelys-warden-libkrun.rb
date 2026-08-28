# typed: strict
# frozen_string_literal: true

require "macho"

# Headless, Warden-scoped build of upstream libkrun.
class MaelysWardenLibkrun < Formula
  desc "Headless libkrun runtime sealed for Maelys Warden"
  homepage "https://warden.maelys.dev"
  url "https://github.com/containers/libkrun/archive/refs/tags/v1.19.4.tar.gz"
  sha256 "e8775fab2b460972a67ca6cd936296bb79cdb078d852d712a283cb290dd0b284"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-warden/releases/download/v0.26.0"
    sha256 cellar: :any, arm64_sequoia: "95abd90ef266418d935800d44f54dc318c1803cfdd1a23ed5540bf9eb1b7d7d6"
    sha256 cellar: :any, arm64_tahoe:   "bb1e50b646425f5a1d6ce7f011cf68d8afb3d2f63f78cc2e5226c00ed31e609d"
  end

  keg_only "warden loads this private runtime through its dedicated opt path"

  depends_on "dtc" => :build
  depends_on "rust" => :build
  depends_on arch: :arm64
  depends_on "libkrun/krun/libkrunfw"
  depends_on macos: :sequoia

  def install
    # Warden supplies its own init in the sealed ext4 root and uses vsock for
    # networking. Build only block support, not the whole Cargo workspace.
    system formula_opt_bin("rust")/"cargo", "build", "--locked", "--release", "--package", "libkrun",
           "--no-default-features", "--features", "blk"
    # Cargo leaves target/release/libkrun.dylib as a symlink into deps/.  Move
    # the real file into the Cellar so the installed aliases cannot dangle.
    dylib = (buildpath/"target/release/libkrun.dylib").realpath
    MachO::Tools.change_dylib_id dylib.to_s, (lib/"libkrun.1.dylib").to_s
    lib.install dylib => "libkrun.1.19.4.dylib"
    lib.install_symlink "libkrun.1.19.4.dylib" => "libkrun.1.dylib"
    lib.install_symlink "libkrun.1.dylib" => "libkrun.dylib"
    include.install "include/libkrun.h"
    (lib/"pkgconfig/libkrun.pc").write <<~EOS
      prefix=#{prefix}
      libdir=${prefix}/lib
      includedir=${prefix}/include

      Name: libkrun
      Description: Headless libkrun runtime for Maelys Warden
      Version: #{version}
      Libs: -L${libdir} -lkrun
      Cflags: -I${includedir}
    EOS
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <libkrun.h>
      int main(void) {
        int context = krun_create_ctx();
        if (context < 0) return 1;
        return krun_free_ctx((unsigned int)context) < 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lkrun", "-o", "test"
    system "./test"
    linked = shell_output("otool -L #{lib}/libkrun.1.dylib")
    refute_match "libepoxy", linked
    refute_match "virglrenderer", linked
    refute_match "MoltenVK", linked
  end
end

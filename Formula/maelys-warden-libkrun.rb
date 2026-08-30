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
  revision 1

  bottle do
    root_url "https://github.com/maelys-dev/maelys-warden/releases/download/v0.38.0"
    sha256 cellar: :any, arm64_sequoia: "99b9ee7c0dc52090f97303f233a0bd3e7ee9c0742735686101bddca72f07e303"
    sha256 cellar: :any, arm64_tahoe:   "13f55cbfb163a89b1d7fdc781a0c96be768267975149f88c44a434581718e5ad"
  end

  keg_only "warden loads this private runtime through its dedicated opt path"

  depends_on "dtc" => :build
  depends_on "rust" => :build
  depends_on arch: :arm64
  depends_on macos: :sequoia

  patch do
    url "https://raw.githubusercontent.com/maelys-dev/maelys-warden/e471dbd00af0d700dce5b610dd679b3ea6ffe181/packaging/patches/libkrun-1.19.4-external-kernel-only.patch"
    sha256 "f745fa51525ffc3b1b8cdc218384c244c51f207971fe19fc0faad32de6c06b1f"
  end

  def install
    # Warden always supplies its sealed raw kernel. The downstream feature
    # removes libkrunfw loading and fails closed if no external kernel exists.
    system formula_opt_bin("rust")/"cargo", "build", "--locked", "--release", "--package", "libkrun",
           "--no-default-features", "--features", "blk,external-kernel-only"
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
        static const unsigned char init[] = {0x7f, 'E', 'L', 'F'};
        if (krun_has_feature(KRUN_FEATURE_BLK) != 1 ||
            krun_has_feature(KRUN_FEATURE_INIT_BLOB) != 0) return 2;
        int context = krun_create_ctx();
        if (context < 0) return 1;
        if (krun_disable_implicit_init((unsigned int)context) < 0) return 3;
        if (krun_add_virtiofs4((unsigned int)context, "/dev/root", 0, 0,
                               false, KRUN_SEMANTICS_LINUX_COMPLETE) < 0) return 4;
        if (krun_fs_add_overlay_file((unsigned int)context, "/dev/root",
                                     "init.krun", init, sizeof(init),
                                     0100755, true) < 0) return 5;
        return krun_free_ctx((unsigned int)context) < 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lkrun", "-o", "test"
    system "./test"
    linked = shell_output("otool -L #{lib}/libkrun.1.dylib")
    refute_match "libepoxy", linked
    refute_match "virglrenderer", linked
    refute_match "MoltenVK", linked
    refute_match "libkrunfw", shell_output("strings #{lib}/libkrun.1.dylib")
  end
end

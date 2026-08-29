require "json"
require "digest"

class MaelysWardenKrunDriver < Formula
  desc "Optional libkrun microVM driver for Maelys Warden"
  homepage "https://warden.maelys.dev"
  url "https://github.com/maelys-dev/maelys-warden/releases/download/v0.33.0/maelys-warden-krun-driver-0.33.0-macos-arm64.tar.gz"
  version "0.33.0"
  sha256 "f9bbf58c16ac4e5df33fb6b9c2ba6d9db9482c6e782dbd454e42c5c6070c33f0"
  license all_of: ["MIT", "Apache-2.0"]

  depends_on arch: :arm64
  depends_on macos: :sequoia
  depends_on "maelys-dev/tap/maelys-warden"
  depends_on "maelys-dev/tap/maelys-warden-guest-kernel"
  depends_on "maelys-dev/tap/maelys-warden-libkrun"
  depends_on "maelys-dev/tap/maelys-warden-oci-tools"

  def install
    libexec.install "usr/local/libexec/maelys-warden-krun-driver"
    (share/"doc/maelys-warden-krun-driver").install(
      Dir["usr/local/share/doc/maelys-warden-krun-driver/*"],
    )
  end

  def caveats
    <<~EOS
      This is a private optional Warden driver, not a standalone CLI. It uses
      Warden's headless libkrun package and the upstream libkrunfw firmware.
      It requires Apple Hypervisor support. The headless runtime deliberately
      omits libepoxy, virglrenderer and MoltenVK; install the official upstream
      libkrun formula separately only when another application needs graphics.

      Before installation, explicitly authorize the upstream dependency tap:
        brew tap libkrun/krun
        brew trust libkrun/krun

      On macOS Tahoe, install the checksum-pinned firmware source first while
      the upstream 5.5.0 bottle metadata is broken:
        brew install --build-from-source libkrun/krun/libkrunfw
    EOS
  end

  test do
    driver = libexec/"maelys-warden-krun-driver"
    materializer = formula_opt_libexec("maelys-dev/tap/maelys-warden-oci-tools")/
                   "maelys-warden-oci-materializer"
    system "codesign", "--verify", "--strict", driver
    assert_match "/opt/homebrew/opt/maelys-warden-libkrun/lib/libkrun.1.dylib",
                 shell_output("otool -L #{driver}")
    assert_match "/opt/homebrew/opt/libkrunfw/lib/libkrunfw.5.dylib",
                 shell_output("otool -L #{driver}")
    system "sh", "-c", "#{driver} --probe --proof-fd 3 3>/dev/null"
    assert_match "usage:", shell_output("#{materializer} 2>&1", 64)
    requirements = JSON.parse(
      (share/"doc/maelys-warden-krun-driver/requirements.json").read,
    )
    assert_equal "maelys.warden.krun-driver/v3", requirements["schema"]
    assert_equal "1.19.4", requirements["libkrunVersion"]
    assert_equal "warden-headless", requirements["runtimeVariant"]
    assert_equal "blk", requirements["libkrunFeatures"]
    assert_equal false, requirements["tsi"]
    assert_equal requirements["materializerSha256"],
                 Digest::SHA256.file(materializer).hexdigest
    guest_manifest = formula_opt_libexec("maelys-dev/tap/maelys-warden-oci-tools")/
                     "maelys-warden/guest/linux-arm64/manifest.json"
    assert_equal requirements["guestBundleManifestSha256"],
                 Digest::SHA256.file(guest_manifest).hexdigest
    kernel_manifest = Formula["maelys-dev/tap/maelys-warden-guest-kernel"].opt_share/
                      "maelys-warden/guest/manifest.json"
    assert_equal requirements["guestKernelManifestSha256"],
                 Digest::SHA256.file(kernel_manifest).hexdigest
  end
end

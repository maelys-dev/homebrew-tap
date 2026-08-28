require "json"

class MaelysWardenKrunDriver < Formula
  desc "Optional libkrun microVM driver for Maelys Warden"
  homepage "https://warden.maelys.dev"
  url "https://github.com/maelys-dev/maelys-warden/releases/download/v0.29.0/maelys-warden-krun-driver-0.29.0-macos-arm64.tar.gz"
  version "0.29.0"
  sha256 "ef06d8dbc4249de62dca575fea7017d0e9076475ad2d8a3e7c8343e6ee9c131d"
  license all_of: ["MIT", "Apache-2.0"]

  depends_on arch: :arm64
  depends_on "e2fsprogs"
  depends_on "jansson"
  depends_on "libarchive"
  depends_on macos: :sequoia
  depends_on "maelys-dev/tap/maelys-warden"
  depends_on "maelys-dev/tap/maelys-warden-libkrun"

  def install
    libexec.install "usr/local/libexec/maelys-warden-krun-driver"
    libexec.install "usr/local/libexec/maelys-warden-oci-materializer"
    (libexec/"maelys-warden/guest/linux-arm64").install(
      Dir["usr/local/libexec/maelys-warden/guest/linux-arm64/*"],
    )
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
    materializer = libexec/"maelys-warden-oci-materializer"
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
    assert_equal "1.19.4", requirements["libkrunVersion"]
    assert_equal "warden-headless", requirements["runtimeVariant"]
    assert_equal "blk", requirements["libkrunFeatures"]
    assert_equal false, requirements["tsi"]
  end
end

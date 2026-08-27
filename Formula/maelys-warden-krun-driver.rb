require "json"

class MaelysWardenKrunDriver < Formula
  desc "Optional libkrun microVM driver for Maelys Warden"
  homepage "https://warden.maelys.dev"
  url "https://github.com/maelys-dev/maelys-warden/releases/download/v0.19.0/maelys-warden-krun-driver-0.19.0-macos-arm64.tar.gz"
  version "0.19.0"
  sha256 "b674b85c48f508e596c91743c5322e7813bbcbe755d29be4923218bea1f9b563"
  license all_of: ["MIT", "Apache-2.0"]

  depends_on arch: :arm64
  depends_on "libkrun/krun/libkrun"
  depends_on macos: :sequoia
  depends_on "maelys-dev/tap/maelys-warden"

  def install
    libexec.install "usr/local/libexec/maelys-warden-krun-driver"
    (share/"maelys-warden/krun").install(
      "usr/local/share/maelys-warden/krun/maelys-init-linux-arm64",
    )
    (share/"doc/maelys-warden-krun-driver").install(
      Dir["usr/local/share/doc/maelys-warden-krun-driver/*"],
    )
  end

  def caveats
    <<~EOS
      This is a private optional Warden driver, not a standalone CLI. It uses
      the libkrun/krun tap's libkrun and libkrunfw packages and requires Apple
      Hypervisor support. Warden will not advertise a krun backend until the
      remaining sealed-rootfs and host-confinement gates are satisfied.

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
    system "codesign", "--verify", "--strict", driver
    assert_match "/opt/homebrew/opt/libkrun/lib/libkrun.1.dylib",
                 shell_output("otool -L #{driver}")
    assert_match "/opt/homebrew/opt/libkrunfw/lib/libkrunfw.5.dylib",
                 shell_output("otool -L #{driver}")
    system "sh", "-c", "#{driver} --probe --proof-fd 3 3>/dev/null"
    requirements = JSON.parse(
      (share/"doc/maelys-warden-krun-driver/requirements.json").read,
    )
    assert_equal "1.19.4", requirements["libkrunVersion"]
    assert_equal false, requirements["tsi"]
  end
end

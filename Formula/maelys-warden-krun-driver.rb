require "json"

class MaelysWardenKrunDriver < Formula
  desc "Optional libkrun microVM driver for Maelys Warden"
  homepage "https://warden.maelys.dev"
  url "https://github.com/maelys-dev/maelys-warden/releases/download/v0.21.1/maelys-warden-krun-driver-0.21.1-macos-arm64.tar.gz"
  version "0.21.1"
  sha256 "3f8e41129a9f0d2b28a81ae4d3a4c8ced0d3d08c340e4b4d9b39c1c994f9ea04"
  license all_of: ["MIT", "Apache-2.0"]

  depends_on arch: :arm64
  depends_on "e2fsprogs"
  depends_on "jansson"
  depends_on "libarchive"
  depends_on "libkrun/krun/libkrun"
  depends_on macos: :sequoia
  depends_on "maelys-dev/tap/maelys-warden"

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
      the libkrun/krun tap's libkrun and libkrunfw packages and requires Apple
      Hypervisor support. Warden advertises it only for the proven K5 subset:
      sealed Linux/arm64 OCI roots, network:none, and trusted workspace views.
      Mediated networking and portable filesystem rules remain fail-closed
      until their separate K7 and K6 candidates are delivered.

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
    assert_match "/opt/homebrew/opt/libkrun/lib/libkrun.1.dylib",
                 shell_output("otool -L #{driver}")
    assert_match "/opt/homebrew/opt/libkrunfw/lib/libkrunfw.5.dylib",
                 shell_output("otool -L #{driver}")
    system "sh", "-c", "#{driver} --probe --proof-fd 3 3>/dev/null"
    assert_match "usage:", shell_output("#{materializer} 2>&1", 64)
    requirements = JSON.parse(
      (share/"doc/maelys-warden-krun-driver/requirements.json").read,
    )
    assert_equal "1.19.4", requirements["libkrunVersion"]
    assert_equal false, requirements["tsi"]
  end
end

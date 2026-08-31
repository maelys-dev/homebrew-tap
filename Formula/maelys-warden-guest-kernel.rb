require "json"

class MaelysWardenGuestKernel < Formula
  desc "Pinned Linux guest kernel for Maelys Warden VM backends"
  homepage "https://warden.maelys.dev"
  url "https://github.com/maelys-dev/maelys-warden/releases/download/v0.42.0/maelys-warden-guest-kernel-0.42.0-linux-arm64.tar.gz"
  version "0.42.0"
  sha256 "2a05ba81fe0490afcabd36f393bae988e01eb38732ff424c9e37ebc7cb21855a"
  license "GPL-2.0-only"

  depends_on arch: :arm64
  depends_on macos: :sequoia

  def install
    (share/"maelys-warden/guest").install(
      "usr/local/share/maelys-warden/guest/vmlinux-arm64",
      "usr/local/share/maelys-warden/guest/config-arm64",
      "usr/local/share/maelys-warden/guest/manifest.json",
    )
    (share/"doc/maelys-warden-guest-kernel").install(
      Dir["usr/local/share/doc/maelys-warden-guest-kernel/*"],
    )
  end

  test do
    manifest = JSON.parse((share/"maelys-warden/guest/manifest.json").read)
    assert_equal "maelys.warden.guest-kernel/v1", manifest["schema"]
    assert_equal "linux/arm64", manifest["platform"]
    assert_equal "absent", manifest["tsi"]
    assert_path_exists share/"maelys-warden/guest/vmlinux-arm64"
  end
end

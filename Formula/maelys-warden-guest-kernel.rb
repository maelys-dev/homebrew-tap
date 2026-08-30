require "json"

class MaelysWardenGuestKernel < Formula
  desc "Pinned Linux guest kernel for Maelys Warden VM backends"
  homepage "https://warden.maelys.dev"
  url "https://github.com/maelys-dev/maelys-warden/releases/download/v0.36.0/maelys-warden-guest-kernel-0.36.0-linux-arm64.tar.gz"
  version "0.36.0"
  sha256 "bc0fdbbd14e7ef590448f44984658588ef7fc92da08f98984a90287e737976eb"
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

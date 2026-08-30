require "json"

class MaelysWardenOciTools < Formula
  desc "Shared OCI materializer and guest runtime for Maelys Warden"
  homepage "https://warden.maelys.dev"
  url "https://github.com/maelys-dev/maelys-warden/releases/download/v0.39.1/maelys-warden-oci-tools-0.39.1-macos-arm64.tar.gz"
  version "0.39.1"
  sha256 "f61fac23de5b1811a51a4e90e0013c4aa2ba89a82df1a3c99ef49e0cedf1eb68"
  license all_of: ["MIT", "Apache-2.0"]

  depends_on arch: :arm64
  depends_on "e2fsprogs"
  depends_on "jansson"
  depends_on "libarchive"
  depends_on macos: :sequoia
  depends_on "maelys-dev/tap/maelys-warden"

  def install
    libexec.install "usr/local/libexec/maelys-warden-oci-materializer"
    (libexec/"maelys-warden/guest/linux-arm64").install(
      Dir["usr/local/libexec/maelys-warden/guest/linux-arm64/*"],
    )
    (share/"doc/maelys-warden-oci-tools").install(
      Dir["usr/local/share/doc/maelys-warden-oci-tools/*"],
    )
  end

  test do
    materializer = libexec/"maelys-warden-oci-materializer"
    assert_match "usage:", shell_output("#{materializer} 2>&1", 64)
    requirements = JSON.parse(
      (share/"doc/maelys-warden-oci-tools/requirements.json").read,
    )
    assert_equal "maelys.warden.oci-tools/v1", requirements["schema"]
    assert_equal "MI/6", requirements["guestProtocol"]
    assert_predicate libexec/"maelys-warden/guest/linux-arm64/maelys-init",
                     :executable?
  end
end

require "json"

class MaelysWardenOciTools < Formula
  desc "Shared OCI materializer and guest runtime for Maelys Warden"
  homepage "https://warden.maelys.dev"
  url "https://github.com/maelys-dev/maelys-warden/releases/download/v1.0.0/maelys-warden-oci-tools-1.0.0-macos-arm64.tar.gz"
  version "1.0.0"
  sha256 "a94dc9fab3e9ca55c282af1ab028522b03a0c4ce7888eecb792fdc0a3ea882bd"
  license all_of: ["MPL-2.0", "Apache-2.0"]

  depends_on arch: :arm64
  depends_on "e2fsprogs"
  depends_on "jansson"
  depends_on "libarchive"
  depends_on "mbedtls"
  depends_on macos: :sequoia
  depends_on "maelys-dev/tap/maelys-warden"

  def install
    libexec.install "usr/local/libexec/maelys-warden-oci-materializer"
    libexec.install "usr/local/libexec/maelys-warden-oci-puller"
    (libexec/"maelys-warden/guest/linux-arm64").install(
      Dir["usr/local/libexec/maelys-warden/guest/linux-arm64/*"],
    )
    (share/"doc/maelys-warden-oci-tools").install(
      Dir["usr/local/share/doc/maelys-warden-oci-tools/*"],
    )
  end

  test do
    materializer = libexec/"maelys-warden-oci-materializer"
    puller = libexec/"maelys-warden-oci-puller"
    assert_match "usage:", shell_output("#{materializer} 2>&1", 64)
    assert_match "usage:", shell_output("#{puller} 2>&1", 64)
    requirements = JSON.parse(
      (share/"doc/maelys-warden-oci-tools/requirements.json").read,
    )
    assert_equal "maelys.warden.oci-tools/v2", requirements["schema"]
    assert_equal "MI/6", requirements["guestProtocol"]
    assert_predicate libexec/"maelys-warden/guest/linux-arm64/maelys-init",
                     :executable?
  end
end

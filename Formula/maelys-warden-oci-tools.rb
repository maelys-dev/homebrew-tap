require "json"

class MaelysWardenOciTools < Formula
  desc "Shared OCI materializer and guest runtime for Maelys Warden"
  homepage "https://warden.maelys.dev"
  url "https://github.com/maelys-dev/maelys-warden/releases/download/v0.35.0/maelys-warden-oci-tools-0.35.0-macos-arm64.tar.gz"
  version "0.35.0"
  sha256 "c17b07b73281525e746c3d04f76c616d76ef3f988854f3a055d6b256913b8f62"
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
    assert_equal "MI/5", requirements["guestProtocol"]
    assert_predicate libexec/"maelys-warden/guest/linux-arm64/maelys-init",
                     :executable?
  end
end

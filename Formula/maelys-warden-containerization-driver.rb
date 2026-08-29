require "json"
require "digest"

class MaelysWardenContainerizationDriver < Formula
  desc "Direct Apple Containerization backend for Maelys Warden"
  homepage "https://warden.maelys.dev"
  url "https://github.com/maelys-dev/maelys-warden/releases/download/v0.35.0/maelys-warden-containerization-driver-0.35.0-macos-arm64.tar.gz"
  version "0.35.0"
  sha256 "c82d3e32cb6f235129f4d0083b20854cdf8a73345f29131ac2f0502084da2028"
  license all_of: ["MIT", "Apache-2.0"]

  depends_on arch: :arm64
  depends_on macos: :tahoe
  depends_on "maelys-dev/tap/maelys-warden"
  depends_on "maelys-dev/tap/maelys-warden-guest-kernel"
  depends_on "maelys-dev/tap/maelys-warden-oci-tools"

  def install
    libexec.install "usr/local/libexec/maelys-warden-containerization-driver"
    (share/"doc/maelys-warden-containerization-driver").install(
      Dir["usr/local/share/doc/maelys-warden-containerization-driver/*"],
    )
  end

  def caveats
    <<~EOS
      This is the direct Containerization backend. It does not require the
      Apple `container` CLI and never compiles Swift on the user's machine.
    EOS
  end

  test do
    driver = libexec/"maelys-warden-containerization-driver"
    system "codesign", "--verify", "--strict", driver
    requirements = JSON.parse(
      (share/"doc/maelys-warden-containerization-driver/requirements.json").read,
    )
    assert_equal "0.41.0", requirements["containerizationVersion"]
    assert_equal "MI/5", requirements["guestProtocol"]
    init = formula_opt_libexec("maelys-dev/tap/maelys-warden-oci-tools")/
           "maelys-warden/guest/linux-arm64/maelys-init"
    assert_predicate init, :executable?
    assert_equal requirements["guestInitSha256"], Digest::SHA256.file(init).hexdigest
  end
end

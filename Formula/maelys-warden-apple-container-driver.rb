require "json"

class MaelysWardenAppleContainerDriver < Formula
  desc "Optional Apple Container backend for Maelys Warden"
  homepage "https://warden.maelys.dev"
  url "https://github.com/maelys-dev/maelys-warden/releases/download/v0.21.0/maelys-warden-apple-container-driver-0.21.0-macos-arm64.tar.gz"
  version "0.21.0"
  sha256 "42fa138bd517d35cf83a8c23572da0af2b86d4e9e5171f8c50550174449aa058"
  license all_of: ["MIT", "Apache-2.0"]

  depends_on arch: :arm64
  depends_on macos: :tahoe
  depends_on "maelys-dev/tap/maelys-warden"

  def install
    libexec.install "usr/local/libexec/maelys-warden-apple-container-driver"
    (share/"doc/maelys-warden-apple-container-driver").install(
      Dir["usr/local/share/doc/maelys-warden-apple-container-driver/*"],
    )
  end

  def caveats
    <<~EOS
      This optional backend requires Apple Container 1.3.0 to be installed and
      configured. It does not install Xcode and never compiles Swift locally.
      Warden discovers the packaged driver through this formula's stable opt path.
    EOS
  end

  test do
    system "codesign", "--verify", "--strict",
           "#{libexec}/maelys-warden-apple-container-driver"
    requirements = JSON.parse(
      (share/"doc/maelys-warden-apple-container-driver/requirements.json").read,
    )
    assert_equal "1.3.0", requirements["appleContainerVersion"]
  end
end

# typed: strict
# frozen_string_literal: true

# Rendered by the socle's tap workflow from this template, through
# scripts/render-homebrew-formula.sh: https://github.com/maelys-dev/maelys-http/releases/download/v0.1.18/maelys-http-0.1.18.tar.gz, 0.1.18 and 36445b4563af0172ca4853d1def98b4ab3c5789445318c0423b29fd032d26aad name the
# published source archive of one tag and the digest of those exact bytes,
# and 0.14.4 in the comment below is copied from
# dependencies/maelys-system.pin held inside that same archive. Nothing here
# is typed at release time.
class LibmaelysHttp < Formula
  desc "Bounded HTTP/1.1 codec and streaming client"
  homepage "https://github.com/maelys-dev/maelys-http"
  url "https://github.com/maelys-dev/maelys-http/releases/download/v0.1.18/maelys-http-0.1.18.tar.gz"
  sha256 "36445b4563af0172ca4853d1def98b4ab3c5789445318c0423b29fd032d26aad"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-http/releases/download/v0.1.18"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d91b8651df4a81f7e520bd401377729edafcca2b789b54590ab09c8a38f6326c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "05c9d7a0bf6f6e9516f88095280a8d4daed950cce66f863c3c9ffd94274c8e12"
  end

  depends_on "libmaelys-sys"
  # Not optional: consumers link libmaelys_http_tls_mbedtls.a, so the provider
  # is part of what this formula installs.
  depends_on "mbedtls"

  def install
    # Built and tested against Maelys System 0.14.4, the version
    # dependencies/maelys-system.pin names at this tag.
    sys = Formula["libmaelys-sys"]
    args = ["SYSTEM_DIR=#{sys.opt_prefix}",
            "SYSTEM_LIB=#{sys.opt_lib}/libmaelys_sys.a"]
    system "make", "all", *args
    system "make", "install", "PREFIX=#{prefix}", *args
    # REQUIRE_MBEDTLS=1 turns a provider pkg-config cannot see into a failure
    # rather than a silent skip that would install no TLS archive at all.
    system "make", "install-mbedtls", "PREFIX=#{prefix}", "REQUIRE_MBEDTLS=1", *args
  end

  test do
    sys = Formula["libmaelys-sys"]
    mbed = Formula["mbedtls"]
    # The codec and the client, linked as a consumer links them. The ABI
    # version is read, never asserted equal to a number: this test must not
    # need editing when the ABI moves.
    (testpath/"smoke.c").write <<~EOS
      #include <maelys/http.h>
      #include <maelys/http_client.h>
      int main(void) {
        maelys_http_limits_t parser;
        maelys_http_client_limits_t client;
        maelys_http_limits_default(&parser);
        maelys_http_client_limits_default(&client);
        return MAELYS_HTTP_ABI_VERSION == 0u ||
               parser.max_header_count == 0u || client.io_buffer_bytes == 0u;
      }
    EOS
    system ENV.cc, "-std=c11", "-I#{include}", testpath/"smoke.c",
           "-L#{lib}", "-lmaelys_http_client", "-lmaelys_http",
           "#{sys.opt_lib}/libmaelys_sys.a", "-pthread", "-o", testpath/"smoke"
    system testpath/"smoke"

    # The TLS provider archive is what maelys-oci links, so prove it links.
    (testpath/"tls.c").write <<~EOS
      #include <maelys/http_tls_modules.h>
      int main(void) {
        return maelys_http_tls_mbedtls_client_create(0, 0, 0) ==
               MAELYS_HTTP_ERR_ARGUMENT ? 0 : 1;
      }
    EOS
    system ENV.cc, "-std=c11", "-I#{include}", testpath/"tls.c",
           "-L#{lib}", "-lmaelys_http_tls_mbedtls", "-lmaelys_http",
           "-L#{mbed.opt_lib}", "-lmbedtls", "-lmbedx509", "-lmbedcrypto",
           "-pthread", "-o", testpath/"tls"
    system testpath/"tls"
  end
end

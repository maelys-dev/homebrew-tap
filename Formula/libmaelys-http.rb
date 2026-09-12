# typed: strict
# frozen_string_literal: true

# Rendered by the socle's tap workflow from this template, through
# scripts/render-homebrew-formula.sh: https://github.com/maelys-dev/maelys-http/releases/download/v0.1.14/maelys-http-0.1.14.tar.gz, 0.1.14 and add0b8f3703d9bf5ec8475df3189f45c5fb53ea822476afcaea3bd428a4560ac name the
# published source archive of one tag and the digest of those exact bytes,
# and 0.9.1 in the comment below is copied from
# dependencies/maelys-system.pin held inside that same archive. Nothing here
# is typed at release time.
class LibmaelysHttp < Formula
  desc "Bounded HTTP/1.1 codec and streaming client"
  homepage "https://github.com/maelys-dev/maelys-http"
  url "https://github.com/maelys-dev/maelys-http/releases/download/v0.1.14/maelys-http-0.1.14.tar.gz"
  sha256 "add0b8f3703d9bf5ec8475df3189f45c5fb53ea822476afcaea3bd428a4560ac"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/maelys-dev/maelys-http/releases/download/v0.1.14"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c7adcdc0a858f61e25c8b13b6cd86b44c386d0fd0c953c5cf287044dad906576"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "edf4c2b241335617fe734617fa5368d33e50228c03e0b82598945769410f9aac"
  end

  depends_on "libmaelys-sys"
  # Not optional: consumers link libmaelys_http_tls_mbedtls.a, so the provider
  # is part of what this formula installs.
  depends_on "mbedtls"

  def install
    # Built and tested against Maelys System 0.9.1, the version
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

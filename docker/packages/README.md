# Alpine 3.24 security packages

These packages bridge security updates that are not yet available in the Alpine
3.24 repositories. They are built from verified upstream sources with Alpine
3.24 tools and dependencies. No edge repository or prebuilt edge package is used.

- `curl/APKBUILD` is the Alpine aports `main/curl` recipe for 8.23.0, retrieved
  from the official master branch on 2026-10-24. Its upstream source checksum,
  protocol configuration and nonflaky test suite are preserved. The recipe
  accepts optional test selectors through `CURL_TEST_FLAGS`; the default runs
  the complete upstream suite.
- `libimagequant/APKBUILD` and `Cargo.lock` originate from aports
  `3.24-stable/main/libimagequant` 4.2.2. Only the package revision and minimum
  Rust dependency resolution needed for crossbeam-epoch 0.9.20 are changed.
  The library's C API and SONAME remain unchanged; its upstream tests still run.

The Dockerfile signs these packages with an ephemeral build key and verifies
their signatures during installation. Only runtime packages enter the final
image; build tools, signing keys and package archives stay in build stages.
Curl's checks run with external networking disabled so DNS interception or proxy
configuration cannot change the upstream tests' expected name-resolution errors.

When Alpine 3.24 supplies these fixes, compare the versions and remove the
corresponding local recipe after checking compatibility. Until then, keep source
checksums pinned and rerun upstream checks when updating either recipe.

Some local BuildKit environments cannot connect to IPv6 loopback even when
ordinary Docker containers can. Diagnose that with an unchanged image first.
For those environments only, build with `--build-arg CURL_TEST_FLAGS='!feat:ipv6'`,
then build the `curl-checks` target with the same arguments and run it in an
ordinary isolated container before publishing. Its default command runs the
complete upstream suite without those build-time selectors. Verify that its
compiled library matches the production candidate. Never disable IPv6 in curl
or treat the partial build-time run as complete validation.

Sources:

- https://github.com/alpinelinux/aports/blob/master/main/curl/APKBUILD
- https://github.com/alpinelinux/aports/tree/3.24-stable/main/libimagequant
- https://curl.se/docs/security.html
- https://rustsec.org/advisories/RUSTSEC-2026-0204.html

The default JSON implementation is separately synchronized with the patched gem
already locked by the application using `docker/build/update_default_json.rb`.
That script replaces both Ruby and native implementation files before writing
the matching default gem specification; Bundler continues using the locked gem.

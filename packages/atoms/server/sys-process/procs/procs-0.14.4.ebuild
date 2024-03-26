# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
addr2line-0.21.0
adler-1.0.2
aho-corasick-1.1.2
android-tzdata-0.1.1
android_system_properties-0.1.5
anyhow-1.0.75
async-channel-1.9.0
async-executor-1.6.0
async-global-executor-2.3.1
async-io-1.13.0
async-lock-2.8.0
async-std-1.12.0
async-stream-0.3.5
async-stream-impl-0.3.5
async-task-4.5.0
async-trait-0.1.74
atomic-waker-1.1.2
atty-0.2.14
autocfg-1.1.0
backtrace-0.3.69
base64-0.21.5
bindgen-0.65.1
bindgen-0.68.1
bitflags-1.3.2
bitflags-2.4.1
blocking-1.4.1
bsd-kvm-0.1.3
bsd-kvm-sys-0.2.0
bumpalo-3.14.0
byte-unit-4.0.19
byteorder-1.5.0
bytes-1.5.0
cc-1.0.83
cexpr-0.6.0
cfg-if-1.0.0
chrono-0.4.31
clang-sys-1.6.1
clap-3.2.25
clap_complete-3.2.5
clap_derive-3.2.25
clap_lex-0.2.4
concurrent-queue-2.3.0
console-0.15.7
core-foundation-sys-0.8.4
crc32fast-1.3.2
crossbeam-channel-0.5.8
crossbeam-utils-0.8.16
crossterm-0.19.0
crossterm-0.26.1
crossterm_winapi-0.7.0
crossterm_winapi-0.9.1
directories-5.0.1
dirs-5.0.1
dirs-sys-0.4.1
dockworker-0.3.0
either-1.9.0
encode_unicode-0.3.6
equivalent-1.0.1
errno-0.2.8
errno-0.3.7
errno-dragonfly-0.1.2
event-listener-2.5.3
fastrand-1.9.0
fastrand-2.0.1
filetime-0.2.22
flate2-1.0.28
fnv-1.0.7
form_urlencoded-1.2.0
futures-0.3.29
futures-channel-0.3.29
futures-core-0.3.29
futures-io-0.3.29
futures-lite-1.13.0
futures-macro-0.3.29
futures-sink-0.3.29
futures-task-0.3.29
futures-util-0.3.29
getch-0.3.1
getrandom-0.2.10
gimli-0.28.0
glob-0.3.1
gloo-timers-0.2.6
hashbrown-0.12.3
hashbrown-0.14.2
heck-0.4.1
hermit-abi-0.1.19
hermit-abi-0.3.3
hex-0.4.3
home-0.5.5
http-0.2.9
http-body-0.4.5
httparse-1.8.0
httpdate-1.0.3
hyper-0.14.27
hyperlocal-0.8.0
iana-time-zone-0.1.58
iana-time-zone-haiku-0.1.2
idna-0.4.0
indexmap-1.9.3
indexmap-2.0.2
instant-0.1.12
io-lifetimes-1.0.11
is-terminal-0.4.9
itoa-1.0.9
js-sys-0.3.64
kv-log-macro-1.0.7
lazy_static-1.4.0
lazycell-1.3.0
libc-0.2.150
libloading-0.7.4
libproc-0.14.2
linux-raw-sys-0.3.8
linux-raw-sys-0.4.10
lock_api-0.4.11
log-0.4.20
memchr-2.6.4
memoffset-0.7.1
minimal-lexical-0.2.1
miniz_oxide-0.7.1
minus-5.4.2
mio-0.7.14
mio-0.8.9
miow-0.3.7
named_pipe-0.4.1
nix-0.26.4
nix-0.27.1
nom-7.1.3
ntapi-0.3.7
num-traits-0.2.17
num_cpus-1.16.0
object-0.32.1
once_cell-1.18.0
option-ext-0.2.0
os_str_bytes-6.6.1
pager-0.16.1
parking-2.2.0
parking_lot-0.11.2
parking_lot-0.12.1
parking_lot_core-0.8.6
parking_lot_core-0.9.9
peeking_take_while-0.1.2
percent-encoding-2.3.0
pin-project-1.1.3
pin-project-internal-1.1.3
pin-project-lite-0.2.13
pin-utils-0.1.0
piper-0.2.1
polling-2.8.0
prettyplease-0.2.15
proc-macro-error-1.0.4
proc-macro-error-attr-1.0.4
proc-macro2-1.0.69
procfs-0.16.0
procfs-core-0.16.0
quote-1.0.33
redox_syscall-0.2.16
redox_syscall-0.3.5
redox_syscall-0.4.1
redox_users-0.4.3
regex-1.10.2
regex-automata-0.4.3
regex-syntax-0.8.2
rustc-demangle-0.1.23
rustc-hash-1.1.0
rustix-0.37.27
rustix-0.38.21
ryu-1.0.15
scopeguard-1.2.0
serde-1.0.193
serde_derive-1.0.193
serde_json-1.0.107
serde_spanned-0.6.4
shlex-1.2.0
signal-hook-0.1.17
signal-hook-0.3.17
signal-hook-mio-0.2.3
signal-hook-registry-1.4.1
slab-0.4.9
smallvec-1.11.1
socket2-0.4.10
socket2-0.5.5
strsim-0.10.0
syn-1.0.109
syn-2.0.38
tar-0.4.40
termbg-0.4.3
termcolor-1.3.0
termios-0.3.3
textwrap-0.16.0
thiserror-1.0.50
thiserror-impl-1.0.50
tinyvec-1.6.0
tinyvec_macros-0.1.1
tokio-1.34.0
tokio-macros-2.2.0
tokio-stream-0.1.14
tokio-util-0.7.10
toml-0.8.8
toml_datetime-0.6.5
toml_edit-0.21.0
tower-service-0.3.2
tracing-0.1.40
tracing-core-0.1.32
try-lock-0.2.4
unicode-bidi-0.3.13
unicode-ident-1.0.12
unicode-normalization-0.1.22
unicode-width-0.1.11
url-2.4.1
utf8-width-0.1.6
uzers-0.11.3
value-bag-1.4.2
version_check-0.9.4
waker-fn-1.1.1
want-0.3.1
wasi-0.11.0+wasi-snapshot-preview1
wasm-bindgen-0.2.87
wasm-bindgen-backend-0.2.87
wasm-bindgen-futures-0.4.37
wasm-bindgen-macro-0.2.87
wasm-bindgen-macro-support-0.2.87
wasm-bindgen-shared-0.2.87
web-sys-0.3.64
which-4.4.2
which-5.0.0
winapi-0.3.9
winapi-i686-pc-windows-gnu-0.4.0
winapi-util-0.1.6
winapi-x86_64-pc-windows-gnu-0.4.0
windows-core-0.51.1
windows-sys-0.45.0
windows-sys-0.48.0
windows-targets-0.42.2
windows-targets-0.48.5
windows_aarch64_gnullvm-0.42.2
windows_aarch64_gnullvm-0.48.5
windows_aarch64_msvc-0.42.2
windows_aarch64_msvc-0.48.5
windows_i686_gnu-0.42.2
windows_i686_gnu-0.48.5
windows_i686_msvc-0.42.2
windows_i686_msvc-0.48.5
windows_x86_64_gnu-0.42.2
windows_x86_64_gnu-0.48.5
windows_x86_64_gnullvm-0.42.2
windows_x86_64_gnullvm-0.48.5
windows_x86_64_msvc-0.42.2
windows_x86_64_msvc-0.48.5
winnow-0.5.17
xattr-1.0.1
"

inherit cargo

DESCRIPTION="A modern replacement for ps"
HOMEPAGE="https://github.com/dalance/procs"
SRC_URI="https://api.github.com/repos/dalance/procs/tarball/v0.14.4 -> procs-0.14.4.tar.gz
	$(cargo_crate_uris ${CRATES})"

LICENSE="Apache-2.0 BSD BSD-2 CC0-1.0 MIT ZLIB"
SLOT="0"
KEYWORDS="*"
BDEPEND="app-text/asciidoctor"

src_unpack() {
	cargo_src_unpack
	rm -rf ${S}
	mv ${WORKDIR}/dalance-procs-* ${S} || die
}

src_install() {
	pushd ${S}/man/
	asciidoctor -b manpage procs.1.adoc || die
	doman procs.1
	popd

	# Avoid calling doman from eclass. It fails.
	rm -rf ${S}/man

	cargo_src_install

	dodoc README.md
}
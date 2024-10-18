# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="serial graphics adapter bios option rom for x86"
HOMEPAGE="https://code.google.com/p/sgabios/ https://github.com/qemu/sgabios"
SRC_URI="https://github.com/qemu/sgabios/archive/72f39d48bedf044e202fd51fecf3e2218fc2ae66.zip -> sgabios-0.1_pre10-72f39d4.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

post_src_unpack() {
	mv ${PN}-* ${S}
}

src_compile() {
	tc-ld-disable-gold
	tc-export_build_env BUILD_CC
	emake -j1 \
		BUILD_CC="${BUILD_CC}" \
		BUILD_CFLAGS="${BUILD_CFLAGS}" \
		BUILD_LDFLAGS="${BUILD_LDFLAGS}" \
		BUILD_CPPFLAGS="${BUILD_CPPFLAGS}" \
		CC="$(tc-getCC)" \
		LD="$(tc-getLD)" \
		AR="$(tc-getAR)" \
		OBJCOPY="$(tc-getOBJCOPY)"
}

src_install() {
	insinto /usr/share/sgabios
	doins sgabios.bin
}

# vim: filetype=ebuild
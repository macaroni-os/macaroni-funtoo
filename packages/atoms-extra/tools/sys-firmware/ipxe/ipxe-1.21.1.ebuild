# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit savedconfig toolchain-funcs

DESCRIPTION="Open source network boot (PXE) firmware"
HOMEPAGE="https://ipxe.org/"
SRC_URI="https://github.com/ipxe/ipxe/tarball/988d2c13cdf0f0b4140685af35ced70ac5b3283c -> ipxe-1.21.1-988d2c1.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="efi ipv6 iso lkrn +qemu undi usb vmware"

DEPEND="
	app-arch/xz-utils
	dev-lang/perl
	iso? (
		app-cdr/cdrtools
		sys-boot/syslinux
	)"

post_src_unpack() {
	mv ${PN}-ipxe-* ${S}
}

src_configure() {
	cat > src/config/local/general.h <<-EOF || die
		#undef BANNER_TIMEOUT
		#define BANNER_TIMEOUT 0
	EOF

	if use ipv6; then
		cat >> src/config/local/general.h <<-EOF || die
			#define NET_PROTO_IPV6
		EOF
	fi

	if use vmware; then
		cat >> src/config/local/general.h <<-EOF || die
			#define VMWARE_SETTINGS
			#define CONSOLE_VMWARE
		EOF
	fi

	restore_config src/config/local/general.h

	tc-ld-disable-gold
}

ipxemake() {
	# Q='' makes the build verbose since that's what everyone loves now
	emake Q='' \
		CC="$(tc-getCC)" \
		LD="$(tc-getLD)" \
		AS="$(tc-getAS)" \
		AR="$(tc-getAR)" \
		NM="$(tc-getNM)" \
		OBJCOPY="$(tc-getOBJCOPY)" \
		RANLIB="$(tc-getRANLIB)" \
		OBJDUMP="$(tc-getOBJDUMP)" \
		HOST_CC="$(tc-getBUILD_CC)" \
		"$@"
}

src_compile() {
	export NO_WERROR=1
	pushd src
	if use qemu; then
		ipxemake bin/808610de.rom # pxe-e1000.rom (old)
		ipxemake bin/8086100e.rom # pxe-e1000.rom
		ipxemake bin/80861209.rom # pxe-eepro100.rom
		ipxemake bin/10500940.rom # pxe-ne2k_pci.rom
		ipxemake bin/10222000.rom # pxe-pcnet.rom
		ipxemake bin/10ec8139.rom # pxe-rtl8139.rom
		ipxemake bin/1af41000.rom # pxe-virtio.rom
	fi

	if use vmware; then
		ipxemake bin/8086100f.mrom # e1000
		ipxemake bin/808610d3.mrom # e1000e
		ipxemake bin/10222000.mrom # vlance
		ipxemake bin/15ad07b0.rom # vmxnet3
	fi

	use efi && ipxemake PLATFORM=efi BIN=bin-efi bin-efi/ipxe.efi
	use iso && ipxemake bin/ipxe.iso
	use undi && ipxemake bin/undionly.kpxe
	use usb && ipxemake bin/ipxe.usb
	use lkrn && ipxemake bin/ipxe.lkrn
	popd
}

src_install() {
	pushd src
	insinto /usr/share/ipxe/

	if use qemu || use vmware; then
		doins bin/*.rom
	fi
	use vmware && doins bin/*.mrom
	use efi && doins bin-efi/*.efi
	use iso && doins bin/*.iso
	use undi && doins bin/*.kpxe
	use usb && doins bin/*.usb
	use lkrn && doins bin/*.lkrn

	popd
	save_config src/config/local/general.h
}

# vim: filetype=ebuild
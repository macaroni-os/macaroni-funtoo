# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools

DESCRIPTION="Userspace utilities for a general USB device sharing system over IP networks"
HOMEPAGE="https://www.kernel.org/"
SRC_URI="https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/linux-6.1.106.tar.xz -> linux-6.1.106.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs tcpd"
RESTRICT=""

RDEPEND="
	dev-libs/glib
	sys-apps/hwids
	tcpd? ( sys-apps/tcp-wrappers )"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers
	virtual/pkgconfig"

DOCS="AUTHORS README"

S="${WORKDIR}"/linux-6.1.106/tools/usb/${PN}

src_prepare() {
	# remove -Werror from build, bug #545398
	sed -i 's/-Werror[^ ]* //g' configure.ac || die

	default

	eautoreconf
}

src_configure() {
	econf \
		$(use_enable static-libs static) \
		$(use tcpd || echo --without-tcp-wrappers) \
		--with-usbids-dir=/usr/share/misc
}

src_install() {
	default
	newconfd "${FILESDIR}"/usbipd.confd usbipd || die
	newinitd "${FILESDIR}"/usbipd.initd usbipd || die
}

pkg_postinst() {
	elog "For using USB/IP you need to enable USBIP_VHCI_HCD in the client"
	elog "machine's kernel config and USBIP_HOST on the server."
}

# vim: filetype=ebuild
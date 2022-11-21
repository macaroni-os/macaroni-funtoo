# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gnome3 udev user meson

DESCRIPTION="Bluetooth graphical utilities integrated with GNOME"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeBluetooth"

LICENSE="GPL-2+ LGPL-2.1+ FDL-1.1+"
SLOT="2/13" # subslot = libgnome-bluetooth soname version
KEYWORDS="*"

IUSE="debug +introspection"

COMMON_DEPEND="
	>=dev-libs/glib-2.62.2:2
	media-libs/libcanberra[gtk3]
	>=x11-libs/gtk+-3.24.12:3[introspection?]
	x11-libs/libnotify
	virtual/udev
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
"
RDEPEND="${COMMON_DEPEND}
	>=net-wireless/bluez-5.50
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/meson-0.49.2
	!net-wireless/bluez-gnome
	app-text/docbook-xml-dtd:4.1.2
	dev-libs/libxml2:2
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1.9
	>=dev-util/intltool-0.40.0
	dev-util/itstool
	virtual/libudev
	virtual/pkgconfig
	x11-base/xorg-proto
"

PATCHES=(
	"${FILESDIR}/gnome-bluetooth-meson-0.63.patch"
)

pkg_setup() {
	enewgroup plugdev
}

src_configure() {
	local emesonargs=(
		-Dicon_update=false
		$(meson_use introspection)
		-Dgtk_doc=true
	)

	meson_src_configure
}

src_install() {
	meson_src_install
	udev_dorules "${FILESDIR}"/61-${PN}.rules
}

pkg_postinst() {
	gnome3_pkg_postinst
	if ! has_version sys-auth/consolekit[acl] && ! has_version sys-apps/systemd[acl] ; then
		elog "Don't forget to add yourself to the plugdev group "
		elog "if you want to be able to control bluetooth transmitter."
	fi
}

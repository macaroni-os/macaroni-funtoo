# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome3 meson

DESCRIPTION="A document manager application for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Documents"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE=""

# cairo-1.14 for cairo_surface_set_device_scale check and usage
COMMON_DEPEND="
	>=app-text/evince-3.13.3[introspection]
	>=net-libs/webkit-gtk-2.6:4[introspection]
	dev-libs/gjs
	>=dev-libs/glib-2.62.2:2
	>=dev-libs/gobject-introspection-1.62.0:=
	>=x11-libs/gtk+-3.24.12:3[introspection]
	>=net-libs/libsoup-2.41.3:2.4
	gnome-base/gnome-desktop:3=[introspection]
	>=app-misc/tracker-2:=[miners]
	>=app-misc/tracker-miners-2:=
	>=x11-libs/cairo-1.16.0
	>=dev-libs/libgdata-0.13.3:=[crypt,gnome-online-accounts,introspection]
	x11-libs/gdk-pixbuf:2[introspection]
	>=net-libs/gnome-online-accounts-3.2.0:=[introspection]
	x11-libs/pango[introspection]
	>=net-libs/libzapojit-0.0.2[introspection]
	>=app-text/libgepub-0.6[introspection]
"
RDEPEND="${COMMON_DEPEND}
	net-misc/gnome-online-miners
	sys-apps/dbus
	x11-themes/adwaita-icon-theme
"
DEPEND="${COMMON_DEPEND}
	dev-libs/libxslt
	>=dev-util/intltool-0.50.1
	dev-util/itstool
	virtual/pkgconfig
"

src_prepare() {
	sed -i -e "s|^libgd_src_path.*|libgd_src_path = './libgd/libgd'|g" \
		-e '/   appdata,/d' -e '/   desktop,/d' \
		data/meson.build
	# Fix sandbox issue
	cd data ; ln -s ../subprojects/libgd/ .; cd -
	gnome3_src_prepare
}

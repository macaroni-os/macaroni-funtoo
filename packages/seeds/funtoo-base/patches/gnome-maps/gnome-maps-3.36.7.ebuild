# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gnome3 meson

DESCRIPTION="A map application for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Maps"

LICENSE="GPL-2+ LGPL-2+ MIT CC-BY-3.0 CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="*"

IUSE=""

COMMON_DEPEND="
	>=app-misc/geoclue-1.99.3:2.0[introspection]
	>=dev-libs/folks-0.10
	>=dev-libs/gjs-1.44.0
	>=dev-libs/gobject-introspection-1.62.0:=
	>=dev-libs/glib-2.62.2:2
	>=dev-libs/libgee-0.16:0.8[introspection]
	dev-libs/libxml2:2
	>=media-libs/libchamplain-0.12.14:0.12[gtk,introspection]
	>=net-libs/rest-0.7.90:0.7[introspection]
	>=sci-geosciences/geocode-glib-3.15.2[introspection]
	>=x11-libs/gtk+-3.24.12:3[introspection]
	app-crypt/libsecret[introspection]
	dev-libs/libgweather[introspection]
	media-libs/clutter-gtk:1.0[introspection]
	media-libs/clutter:1.0[introspection]
	media-libs/cogl:1.0[introspection]
	>=net-libs/gnome-online-accounts-3.36:=[introspection]
	net-libs/libgfbgraph[introspection]
	net-libs/libsoup:2.4[introspection]
	net-libs/webkit-gtk:4[introspection]
	x11-libs/gdk-pixbuf:2[introspection]
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}
	>=dev-util/intltool-0.40
	virtual/pkgconfig
"

src_prepare() {
	sed -i -e '/\tappdata,/d' data/meson.build
	gnome3_src_prepare
}

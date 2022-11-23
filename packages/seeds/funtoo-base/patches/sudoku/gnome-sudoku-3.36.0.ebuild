# Distributed under the terms of the GNU General Public License v2

EAPI=7
VALA_MIN_API_VERSION="0.36"

inherit gnome3 vala meson

DESCRIPTION="Test your logic skills in this number grid puzzle"
HOMEPAGE="https://wiki.gnome.org/Apps/Sudoku"

LICENSE="GPL-3+ CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=dev-libs/glib-2.62.2:2
	dev-libs/libgee:0.8=[introspection]
	dev-libs/json-glib
	>=dev-libs/qqwing-1.3.4
	media-libs/gsound
	x11-libs/gdk-pixbuf:2[introspection]
	>=x11-libs/gtk+-3.24.12:3[introspection]
	x11-libs/pango[introspection]
"
DEPEND="${RDEPEND}
	$(vala_depend)
	app-text/yelp-tools
	dev-libs/appstream-glib
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

src_prepare() {
	sed -i -e "s|'appdata',||g" -e "s|'desktop',||g" data/meson.build
	gnome3_src_prepare
	vala_src_prepare
}

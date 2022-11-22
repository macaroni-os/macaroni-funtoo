# Distributed under the terms of the GNU General Public License v2

EAPI=7
VALA_MIN_API_VERSION="0.24"

inherit gnome3 vala meson

DESCRIPTION="Disassemble a pile of tiles by removing matching pairs"
HOMEPAGE="https://wiki.gnome.org/Apps/Mahjongg"

LICENSE="GPL-2+ CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	>=dev-libs/glib-2.62.2:2
	>=gnome-base/librsvg-2.32:2
	>=x11-libs/gtk+-3.24.12:3
"
DEPEND="${RDEPEND}
	$(vala_depend)
	app-text/yelp-tools
	dev-libs/appstream-glib
	>=dev-util/intltool-0.50
	virtual/pkgconfig
"

src_prepare() {
	sed -i -e "s|('desktop-file',|(|g"  -e "s|('appdata-file',|(|g" data/meson.build
	gnome3_src_prepare
	vala_src_prepare
}

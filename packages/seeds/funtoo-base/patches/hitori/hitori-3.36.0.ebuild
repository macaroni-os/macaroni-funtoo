# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit gnome3 meson

DESCRIPTION="Logic puzzle game for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Hitori"

LICENSE="GPL-3+ CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

# gtk+-3.22 for build-time optional gtk_show_uri_on_window usage
RDEPEND="
	>=dev-libs/glib-2.62.2:2
	>=x11-libs/gtk+-3.24.12:3
	>=x11-libs/cairo-1.16.0
"
DEPEND="${RDEPEND}
	app-text/yelp-tools
	dev-libs/appstream-glib
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

src_prepare() {
	sed  -i -e "s|('desktop-file',|(|g" -e "s|('appdata-file',|(|g" data/meson.build
	gnome3_src_prepare
}

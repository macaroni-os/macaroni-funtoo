# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit meson

DESCRIPTION="Personal task manager"
HOMEPAGE="https://wiki.gnome.org/Apps/Todo"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE="doc +introspection"
SRC_URI="https://ftp.gnome.org/pub/GNOME/sources/gnome-todo/3.28/${P}.tar.xz"

RDEPEND="
	>=dev-libs/glib-2.62.2:2
	>=x11-libs/gtk+-3.24.12:3
	>=net-libs/gnome-online-accounts-3.28.0
	>=gnome-extra/evolution-data-server-3.28.0:=[gtk]
	>=dev-libs/libical-3
	>=dev-libs/libpeas-1.22
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
"
DEPEND="${RDEPEND}
	>=dev-util/meson-0.40.0
	doc? ( dev-util/gtk-doc )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/${P}-autoptr.patch"
	"${FILESDIR}/${P}-libecal-2.0.patch"
)

src_configure() {
	local emesonargs=(
		-Dbackground_plugin=true
		-Ddark_theme_plugin=true
		-Dscheduled_panel_plugin=true
		-Dscore_plugin=true
		-Dtoday_panel_plugin=true
		-Dunscheduled_panel_plugin=true
		-Dtodo_txt_plugin=true
		-Dtodoist_plugin=true
		$(meson_use doc gtk_doc)
		$(meson_use introspection introspection)
	)

	sed -i -e '/  autostart,/d' -e '/  desktop,/d' data/meson.build
	sed -i -e '/  appdata,/d' data/appdata/meson.build

	meson_src_configure
}

src_compile() {
	meson_src_compile
}

src_install() {
	meson_src_install
}

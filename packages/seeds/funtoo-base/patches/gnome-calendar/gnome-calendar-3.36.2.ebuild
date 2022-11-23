# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gnome3 meson

DESCRIPTION="Manage your online calendars with simple and modern interface"
HOMEPAGE="https://wiki.gnome.org/Apps/Calendar"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=dev-libs/glib-2.62.2:2
	>=dev-libs/libical-3
	>=gnome-extra/evolution-data-server-3.17.1:=
	>=net-libs/gnome-online-accounts-${PV%.*}:=
	>=x11-libs/gtk+-3.24.12:3
	>=dev-libs/libdazzle-3.33.1
	>=dev-libs/libgweather-3.27.4
"
DEPEND="${RDEPEND}
	dev-libs/appstream-glib
	>=dev-util/intltool-0.40.6
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	sed -i -e "/  'appdata',/d" data/appdata/meson.build
	gnome3_src_prepare
}

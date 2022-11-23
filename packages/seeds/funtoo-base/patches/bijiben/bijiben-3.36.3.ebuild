# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gnome3 meson

DESCRIPTION="Note editor designed to remain simple to use"
HOMEPAGE="https://wiki.gnome.org/Apps/Bijiben"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE="zeitgeist"

RDEPEND="
	>=dev-libs/glib-2.62.2:2
	>=x11-libs/gtk+-3.24.12:3
	>=gnome-extra/evolution-data-server-3.13.90:=
	>=net-libs/webkit-gtk-2.10.0:4
	>=net-libs/gnome-online-accounts-${PV%.*}
	dev-libs/libxml2
	>=app-misc/tracker-2:=
	sys-apps/util-linux
	zeitgeist? ( gnome-extra/zeitgeist )
"
DEPEND="${RDEPEND}
	app-text/yelp-tools
	dev-libs/appstream-glib
	dev-util/gdbus-codegen
	>=dev-util/intltool-0.50.1
	sys-devel/gettext
	virtual/pkgconfig
"
# Needed if eautoreconf:
# sys-devel/autoconf-archive

src_prepare() {
	# From Fedora:
	# 	http://pkgs.fedoraproject.org/cgit/rpms/bijiben.git/tree/bijiben.spec?h=f27
	sed -i -e 's/tracker-sparql-1\.0/tracker-sparql-2.0/g' configure
	# with-view-common not available on subprojects/libgd
	sed -i -e '/with-view-common/d' meson.build
	sed -i -e '/  info,/d' data/appdata/meson.build
	sed -i -e '/  desktop,/d' -e '/  mime,/d' data/meson.build

	# Fix sandbox issue
	cd data ; ln -s ../subprojects/libgd/ . ; cd -
	sed -i -e 's|../subprojects/libgd|libgd|g' data/meson.build

	gnome3_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use zeitgeist zeitgeist)
		-Dupdate_mimedb=false
	)

	meson_src_configure
}

# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit gnome3 meson

DESCRIPTION="A nautilus extension for sending files to locations"
HOMEPAGE="https://git.gnome.org/browse/nautilus-sendto/"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE="debug"

RDEPEND=">=dev-libs/glib-2.62.2:2"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.19.8
	dev-libs/appstream-glib
	virtual/pkgconfig
"

src_prepare() {
	sed -i -e "s|('appdata',|(|g" src/meson.build
	gnome3_src_prepare
}

pkg_postinst() {
	if ! has_version "gnome-base/nautilus[sendto]"; then
		einfo "Note that ${CATEGORY}/${PN} is meant to be used as a helper by gnome-base/nautilus[sendto]"
	fi
}

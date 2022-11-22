# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gnome3 meson

DESCRIPTION="A set of backgrounds packaged with the GNOME desktop"
HOMEPAGE="https://git.gnome.org/browse/gnome-backgrounds"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="!<x11-themes/gnome-themes-standard-3.14"
DEPEND="
	>=dev-util/intltool-0.40.0
	sys-devel/gettext
"

src_prepare() {
	sed -i -e 's|(metadata,|(|g' backgrounds/meson.build
	gnome3_src_prepare
}

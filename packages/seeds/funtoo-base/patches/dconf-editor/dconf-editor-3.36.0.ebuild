# Distributed under the terms of the GNU General Public License v2

EAPI=7
VALA_MIN_API_VERSION="0.36"

inherit gnome3 meson vala

DESCRIPTION="Graphical tool for editing the dconf configuration database"
HOMEPAGE="https://git.gnome.org/browse/dconf-editor"

LICENSE="LGPL-2.1+"
SLOT="0"

KEYWORDS="*"

PATCHES=(
	"${FILESDIR}/dconf-editor-meson-0.63.patch"
)

COMMON_DEPEND="
	dev-libs/appstream-glib
	>=dev-libs/glib-2.62.2:2
	>=gnome-base/dconf-0.31.2
	>=x11-libs/gtk+-3.24.12:3
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/intltool-0.50
	sys-devel/gettext
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}
	!<gnome-base/dconf-0.22[X]
"

src_prepare() {
	default
	vala_src_prepare
}

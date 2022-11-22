# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"
PYTHON_COMPAT=( python3+ )

inherit gnome3 python-any-r1 vala virtualx meson

DESCRIPTION="Unicode character map viewer and library"
HOMEPAGE="https://wiki.gnome.org/Design/Apps/CharacterMap"

LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="*"

IUSE="test"

RDEPEND="
	>=dev-libs/gjs-1.43.3
	>=dev-libs/glib-2.62.2:2
	>=dev-libs/gobject-introspection-1.62.0:=
	>=dev-libs/libunistring-0.9.5
	>=x11-libs/gtk+-3.24.12:3[introspection]
	>=x11-libs/pango-1.44.7[introspection]
"
DEPEND="${RDEPEND}
	dev-libs/appstream-glib
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	test? (
		${PYTHON_DEPS}
		$(python_gen_any_dep 'dev-util/dogtail[${PYTHON_USEDEP}]') )
"

src_prepare() {
	sed 's/print \(.*\)/print(\1)/' -i "${S}"/tests/smoke_test.py || die
	sed -i -e "/'desktop-file',/d" -e "/'appdata-file',/d" data/meson.build

	gnome3_src_prepare
	vala_src_prepare
}

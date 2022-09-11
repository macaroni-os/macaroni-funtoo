# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python3+ )

inherit gnome.org meson python-single-r1 xdg

DESCRIPTION="Tool to customize GNOME 3 options"
HOMEPAGE="https://wiki.gnome.org/action/show/Apps/GnomeTweakTool"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

PATCHES=(
	"${FILESDIR}"/gnome-tweaks-meson36.patch
)

COMMON_DEPEND="
	${PYTHON_DEPS}
	>=dev-libs/glib-2.62.2:2[dbus]
	$(python_gen_cond_dep '>=dev-python/pygobject-3.30.0:3[${PYTHON_USEDEP}]')
	>=gnome-base/gsettings-desktop-schemas-3.28.1
	!gnome-extra/gnome-tweak-tool
"
# g-s-d, gnome-desktop, gnome-shell etc. needed at runtime for the gsettings schemas
RDEPEND="${COMMON_DEPEND}
	>=gnome-base/gnome-desktop-3.34.1:3=[introspection]
	>=x11-libs/gtk+-3.24.12:3[introspection]

	net-libs/libsoup:2.4[introspection]
	x11-libs/libnotify[introspection]

	>=gnome-base/gnome-settings-daemon-3
	>=gnome-base/gnome-shell-3.32.0
	>=gnome-base/nautilus-3
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"

src_install() {
	meson_src_install
	python_fix_shebang "${ED}"/usr/bin/
}

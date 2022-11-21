# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"

inherit systemd meson

DESCRIPTION="D-Bus interfaces for querying and manipulating user account information"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/AccountsService/"
SRC_URI="https://www.freedesktop.org/software/${PN}/${P}.tar.xz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE="doc elogind +introspection selinux systemd"
REQUIRED_USE="?? ( elogind systemd )"

CDEPEND="
	>=dev-libs/glib-2.62.2:2
	sys-auth/polkit
	elogind? ( >=sys-auth/elogind-229.4 )
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
	systemd? ( >=sys-apps/systemd-186:0= )
	!systemd? ( !elogind? ( sys-auth/consolekit ) )
	sys-apps/dbus
"
DEPEND="${CDEPEND}
	dev-libs/libxslt
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1.15
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig
	doc? (
		app-text/docbook-xml-dtd:4.1.2
		app-text/xmlto )
"
RDEPEND="${CDEPEND}
	selinux? ( sec-policy/selinux-accountsd )
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.6.35-gentoo-system-users.patch
)

src_configure() {
	local mesonargs=(
		--buildtype plain
		--libdir "$(get_libdir)"
		--prefix "${EPREFIX}/usr"
		--sysconfdir "${EPREFIX}/etc"
		--wrap-mode nodownload
		$(meson_use systemd)
		$(meson_use elogind)
		-Dadmin_group="wheel"
		-Dsystemdsystemunitdir="$(systemd_get_systemunitdir)"
		-Dlocalstatedir=/var
		$(meson_use doc docbook)
		$(meson_use introspection)
	)
	sed -i -e "/  policy,/d" data/meson.build
	BUILD_DIR="${BUILD_DIR:-${WORKDIR}/${P}-build}"
	install -d $BUILD_DIR
	set -- meson "${mesonargs[@]}" "$@" \
		"${EMESON_SOURCE:-${S}}" "${BUILD_DIR}"
	echo "$@"
	tc-env_build "$@" || die
}

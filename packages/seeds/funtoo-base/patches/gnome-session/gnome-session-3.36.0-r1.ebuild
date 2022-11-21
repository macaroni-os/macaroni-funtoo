# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit gnome3 meson

DESCRIPTION="Gnome session manager"
HOMEPAGE="https://git.gnome.org/browse/gnome-session"

LICENSE="GPL-2 LGPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="*"

IUSE="consolekit doc elogind man systemd wayland"
REQUIRED_USE="
	?? ( consolekit elogind systemd )
	wayland? ( || ( elogind systemd ) )
"

PATCHES=(
	"${FILESDIR}/gnome-session-meson-0.63.patch"
)

# x11-misc/xdg-user-dirs{,-gtk} are needed to create the various XDG_*_DIRs, and
# create .config/user-dirs.dirs which is read by glib to get G_USER_DIRECTORY_*
# xdg-user-dirs-update is run during login (see 10-user-dirs-update-gnome below).
# gdk-pixbuf used in the inhibit dialog
COMMON_DEPEND="
	>=dev-libs/glib-2.70.0-r1:2=[dbus]
	x11-libs/gdk-pixbuf:2
	>=x11-libs/gtk+-3.24.12:3
	>=dev-libs/json-glib-0.10
	>=gnome-base/gnome-desktop-3.34.1:3
	wayland? ( media-libs/mesa[egl,gles2] )
	!wayland? ( media-libs/mesa[gles2] )

	media-libs/libepoxy
	x11-libs/libSM
	x11-libs/libICE
	x11-libs/libXau
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXext
	x11-libs/libXrender
	x11-libs/libXtst
	x11-misc/xdg-user-dirs
	x11-misc/xdg-user-dirs-gtk
	x11-apps/xdpyinfo

	systemd? ( >=sys-apps/systemd-183:0= )
	elogind? ( sys-auth/elogind )
	consolekit? (
		sys-auth/consolekit
		>=dev-libs/dbus-glib-0.76
	)
"

# Pure-runtime deps from the session files should *NOT* be added here
# Otherwise, things like gdm pull in gnome-shell
# gnome-themes-standard is needed for the failwhale dialog themeing
# sys-apps/dbus[X] is needed for session management
RDEPEND="${COMMON_DEPEND}
	>=gnome-base/gnome-settings-daemon-3.30.0
	>=gnome-base/gsettings-desktop-schemas-3.28.1
	x11-themes/adwaita-icon-theme
	sys-apps/dbus[X]
"

DEPEND="${COMMON_DEPEND}
	dev-libs/libxslt
	>=dev-util/intltool-0.40.6
	>=sys-devel/gettext-0.10.40
	virtual/pkgconfig
	!<gnome-base/gdm-2.20.4
	doc? (
		app-text/xmlto
		dev-libs/libxslt )
"

src_prepare() {
	eapply "${FILESDIR}"/${PN}-3.34.0-support-elogind.patch
	eapply "${FILESDIR}"/${PN}-3.34.2-whitelist-xdg-session-id.patch
	gnome3_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use systemd)
		-Dsystemd_session=$(usex systemd default disable)
		-Dsystemd_journal=$(usex systemd true false)
		$(meson_use consolekit)
		$(meson_use elogind)
		$(meson_use doc docbook)
		$(meson_use man)
	)

	meson_src_configure
}

src_install() {
	meson_src_install

	dodir /etc/X11/Sessions
	exeinto /etc/X11/Sessions
	doexe "${FILESDIR}/Gnome"

	insinto /usr/share/applications
	newins "${FILESDIR}/defaults.list-r4" gnome-mimeapps.list

	dodir /etc/X11/xinit/xinitrc.d/
	exeinto /etc/X11/xinit/xinitrc.d/
	newexe "${FILESDIR}/15-xdg-data-gnome-r1" 15-xdg-data-gnome

	# This should be done here as discussed in bug #270852
	newexe "${FILESDIR}/10-user-dirs-update-gnome-r1" 10-user-dirs-update-gnome

	# Set XCURSOR_THEME from current dconf setting instead of installing
	# default cursor symlink globally and affecting other DEs (bug #543488)
	# https://bugzilla.gnome.org/show_bug.cgi?id=711703
	newexe "${FILESDIR}/90-xcursor-theme-gnome" 90-xcursor-theme-gnome
}

pkg_postinst() {
	gnome3_pkg_postinst

	if ! has_version gnome-base/gdm && ! has_version x11-misc/sddm; then
		ewarn "If you use a custom .xinitrc for your X session,"
		ewarn "make sure that the commands in the xinitrc.d scripts are run."
	fi
}
